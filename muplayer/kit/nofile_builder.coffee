nobone = require 'nobone'

{
    kit,
    kit: {
        _, log, copy, remove, spawn, symlink, Promise,
        path: { join }
    }
} = nobone

class NofileBuilder
    constructor: (options) ->
        defaults =
            dirname: __dirname

            options:
                '-p, --port <8077>': ['Which port to listen to. Example: no -p 8077 server', 8077]
                'r, --rebuild': ['Wheather to rebuild src and doc files before run dev server?']
                '-c, --cli': ['Wheather to run test cases in CLI?']

            tasks:
                'setup': [
                    'Setup project.',
                    =>
                        setup = kit.require './kit/setup', @opts.dirname
                        setup()
                ]

                'build': [
                    'Build all source code.', @_build
                ]

                'doc': [
                    'Build doc.', @_build_doc
                ]

                'server': [
                    'Run dev server.',
                    (opts) =>
                        self = @
                        { port, rebuild } = opts

                        if rebuild
                            @_build()
                            .then ->
                                self._build_doc()
                            .then ->
                                self._server_run(port)
                        else
                            @_server_run(port)
                ]

                'test': [
                    'Run test runner.',
                    (opts) =>
                        if opts.cli
                            @_build()
                            .then ->
                                spawn 'karma', ['start', 'karma.conf.js'].concat([
                                    '--single-run',
                                    '--no-auto-watch',
                                    # Travis supports running a real browser (Firefox) with a virtual screen.
                                    '--browsers', 'Firefox'
                                ])
                        else
                            spawn 'karma', ['start', 'karma.conf.js']
                ]

                'coffeelint': [
                    'Lint all coffee files.',
                    (opts) ->
                        kit.require 'drives'

                        kit.warp ['{src,kit,test}/**/*.coffee', '*.coffee']
                        .load kit.drives.auto 'lint'
                        .load (f) ->
                            f.set null
                        .run()
                ]

        @opts = _.extend(defaults, options)

    build: (handler, handler_type, names) ->
        return unless handler_type in ['option', 'task']
        rs = @opts["#{handler_type}s"]
        for name in names
            args = rs[name]
            if args
                args.unshift(name)
                handler.apply(null, args)

    _build: =>
        Builder = kit.require './kit/builder', @opts.dirname
        builder = new Builder()
        builder.start()

    _build_doc: ->
        symlink_to = (from, to, type = 'dir') ->
            symlink '../' + from, 'doc/' + to, type

        clean = ->
            remove 'doc_temp'

        remove('doc', {
            isFollowLink: false
        }).then ->
            Promise.all([
                spawn('compass', [
                    'compile',
                    '--sass-dir', 'src/css',
                    '--css-dir', 'doc/css',
                    '--no-line-comments'
                ])
                spawn('doxx', [
                    '-d',
                    '-R', 'README.md',
                    '-t', 'MuPlayer 『百度音乐播放内核』',
                    '-s', 'dist',
                    '-T', 'doc_temp',
                    '--template', 'src/doc/base.jade'
                ])
            ])
        .then ->
            copy_to = (from, to) ->
                copy 'doc_temp/' + from, 'doc/' + to

            Promise.all([
                copy_to 'player.js.html', 'api.html'
                copy_to 'index.html', 'index.html'
            ])
        .then ->
            Promise.all [
                # XXX: symlink dist 和 bower_components 是因为为了方便文档站的静态部署：
                # http://labs.music.baidu.com/muplayer/doc/
                symlink_to 'dist', 'dist'
                symlink_to 'bower_components', 'bower_components'
                symlink_to join('src', 'doc', 'img'), 'img'
                symlink_to join('src', 'doc', 'mp3'), 'mp3'
                symlink_to join('src', 'doc', 'js'), 'js'
                symlink_to join('src', 'img', 'favicon.ico'), 'favicon.ico', 'file'
                kit.glob 'src/doc/*.html'
                .then (paths) ->
                    for p in paths
                        to = 'doc/' + kit.path.basename p
                        log '>> Link: '.cyan + p + ' -> '.cyan + to
                        symlink '../' + p, to
            ]
        .then ->
            clean()
        .catch ->
            clean()

    _server_run: (port) ->
        { service, renderer } = nobone()
        service.use '/', renderer.static('doc')
        service.listen port, ->
            log '>> Server start at port: '.cyan + port

module.exports = NofileBuilder
