do (root = @, factory = (cfg, utils, EngineCore, Modernizr) ->
    win = window
    ua = navigator.userAgent
    {TYPES, EVENTS, STATES, ERRCODE} = cfg.engine

    class AudioCore extends EngineCore
        @defaults:
            # Audio是否可以播放的置信度, 可选值是maybe, probably或空字符。
            # 参考: http://www.whatwg.org/specs/web-apps/current-work/multipage/the-video-element.html#dom-navigator-canplaytype
            confidence: 'maybe'
            preload: false
            autoplay: false
            needPlayEmpty: true
            emptyMP3: 'empty.mp3'
        _supportedTypes: []
        engineType: TYPES.AUDIO

        constructor: (options) ->
            @opts = $.extend({}, AudioCore.defaults, options)
            @opts.emptyMP3 = @opts.baseDir + @opts.emptyMP3
            opts = @opts

            levels =
                '': 0
                maybe: 1
                probably: 2
            least = levels[opts.confidence]

            audio = Modernizr.audio
            return @ unless audio
            @_supportedTypes.push(k) for k, v of audio when levels[v] >= least

            _eventHandlers = {}

            # 对于绝大多数浏览器而言, audio标签和Audio对象的方式是等价的。
            # 参考: http://www.jplayer.org/HTML5.Audio.Support/
            audio = new Audio()
            audio.preload = opts.preload
            audio.autoplay = opts.autoplay
            audio.loop = false
            # event listener封装, 支持链式调用。
            audio.on = (type, listener) ->
                audio.addEventListener(type, listener, false)
                listeners = _eventHandlers[type]
                listeners = [] unless listeners
                listeners.push(listener)
                audio
            audio.off = (type, listener) ->
                # remove all events
                # ref: http://stackoverflow.com/a/4386514
                if not type and not listener
                    for type, listeners of _eventHandlers
                        for listener in listeners
                            audio.removeEventListener(type, listener, false)
                else
                    audio.removeEventListener(type, listener, false)
                audio
            @audio = audio

            @_needCanPlay([
                'play', 'setCurrentPosition'
            ])
            @setState(STATES.STOP)._initEvents()

            # 用于HACK Audio在iOS上的限制, 参考: http://www.ibm.com/developerworks/library/wa-ioshtml5/
            if opts.needPlayEmpty
                win.addEventListener('touchstart', @_playEmpty, false)

        _test: ->
            if not Modernizr.audio or not @_supportedTypes.length
                return false
            true

        _playEmpty: =>
            # 当前没有set过url时才set一个空音频，以免影响到成功自动播放的后续交互
            unless @getUrl()
                @setUrl(@opts.emptyMP3).play()
            win.removeEventListener('touchstart', @_playEmpty, false)

        _isEmpty: ->
            @getUrl() is @opts.emptyMP3

        # 事件类型参考: http://www.w3schools.com/tags/ref_eventattributes.asp
        _initEvents: ->
            self = @
            { audio, trigger } = @
            [ errorTimer, progressTimer ]  = [ null, null ]

            @trigger = (type, listener) ->
                return self if self._isEmpty()
                trigger.call(self, type, listener)

            progress = (per) ->
                per = per or self.getLoadedPercent()
                self.trigger(EVENTS.PROGRESS, per)
                if per is 1
                    clearInterval(progressTimer)
                    self._canPlayThrough = true
                    self.setState(STATES.CANPLAYTHROUGH)

            audio.on('loadstart', ->
                # 某些iOS浏览器及Chrome会因歌曲缓存导致progress不被触发，此时使用
                # “万能的”计时器轮询计算加载进度
                clearInterval(progressTimer)
                progressTimer = setInterval( ->
                    progress()
                , 50)
                self.setState(STATES.PREBUFFER)
            ).on('playing', ->
                clearTimeout(errorTimer)
                self.setState(STATES.PLAYING)
            ).on('ended', ->
                self.setState(STATES.END)
            ).on('error', (e) ->
                clearTimeout(errorTimer)
                errorTimer = setTimeout( ->
                    self.trigger(EVENTS.ERROR, e)
                , 2000)
            ).on('waiting', ->
                self.setState(STATES.PREBUFFER)
            ).on('loadeddata', ->
                self.setState(STATES.BUFFERING)
            ).on('timeupdate', ->
                self.trigger(EVENTS.POSITIONCHANGE, self.getCurrentPosition())
            ).on('progress', (e) ->
                clearInterval(progressTimer)
                unless self._canPlayThrough
                    # firefox 3.6 implements e.loaded/total (bytes)
                    loaded = e.loaded or 0
                    total = e.total or 1
                    progress(loaded and (loaded / total).toFixed(2) * 1)
            )

        _needCanPlay: (fnames) ->
            self = @
            audio = @audio
            for name in fnames
                @[name] = utils.wrap @[name], (fn, args...) ->
                    t = null
                    handle = ->
                        clearTimeout(t)
                        fn.apply(self, args)
                        audio.off('canplay', handle)

                    if /webkit/.test ua.toLowerCase()
                        # 对应的编码含义见: http://www.w3schools.com/tags/av_prop_readystate.asp
                        # 小于3认为还没有加载足够数据去播放。
                        if audio.readyState < 3
                            audio.on('canplay', handle)
                        else
                            fn.apply(self, args)
                    else
                        t = setTimeout( ->
                            try
                                fn.apply(self, args)
                            catch e
                                console?.error?('error: ', e)
                        , 1000)
                        audio.on('canplay', handle)

                    self

        destroy: ->
            super()
            @audio.off()
            @

        play: ->
            @audio.play()
            @

        pause: ->
            @audio.pause()

        stop: ->
            # FIXED: https://github.com/Baidu-Music-FE/muplayer/issues/2
            # 不能用setCurrentPosition(0)，似乎是因为_needCanPlay包装器使
            # 该方法成为了非同步方法, 导致执行顺序和预期不符。
            try
                @audio.currentTime = 0
            catch
                return
            finally
                @audio.pause()

        setUrl: (url) ->
            if url
                @audio.src = url
                @audio.load()
            super(url)

        setVolume: (volume) ->
            @audio.volume = volume / 100
            super(volume)

        setMute: (mute) ->
            @audio.muted = mute
            super(mute)

        setState: (st) ->
            return @ if @_isEmpty()
            super(st)

        # audio没有loadedmetadata时, 会报INVALID_STATE_ERR。
        # 相关讨论可参考: https://github.com/johndyer/mediaelement/issues/243
        # 因此需要_needCanPlay的包装。
        setCurrentPosition: (ms) ->
            try
                # XXX: 即便做了canplay的事件判断，
                # 如果server端没有正确处理response header，
                # 依然可能无法成功设置播放进度。相关讨论见：
                # https://github.com/videojs/video.js/issues/792
                @audio.currentTime = ms / 1000
            catch
                return
            finally
                @play()
            @

        getCurrentPosition: ->
            ~~(@audio.currentTime * 1000)

        getLoadedPercent: ->
            audio = @audio
            # buffered end
            be = audio.currentTime
            # buffered是一个Buffer实例
            buffered = audio.buffered

            if buffered
                bl = buffered.length

                # 有多个缓存区间时, 查找当前缓冲使用的区间, 浏览器会自动合并缓冲区间。
                while bl--
                    if buffered.start(bl) <= audio.currentTime <= buffered.end(bl)
                        be = buffered.end(bl)
                        break

            duration = @getTotalTime() / 1000

            # 修复部分浏览器出现buffered end > duration的异常。
            be = if be > duration then duration else be
            duration and (be / duration).toFixed(2) * 1 or 0

        getTotalTime: ->
            { duration, buffered, currentTime } = @audio

            duration = ~~duration
            if duration is 0 and buffered
                bl = buffered.length
                if bl > 0
                    duration = buffered.end(--bl)
                else
                    duration = currentTime

            duration and duration * 1000 or 0

    AudioCore
) ->
    if typeof exports is 'object'
        module.exports = factory()
    else if typeof define is 'function' and define.amd
        define([
            'muplayer/core/cfg'
            'muplayer/core/utils'
            'muplayer/core/engines/engineCore'
            'muplayer/lib/modernizr.audio'
        ], factory)
    else
        root._mu.AudioCore = factory(
            _mu.cfg
            _mu.utils
            _mu.EngineCore
            _mu.Modernizr
        )
