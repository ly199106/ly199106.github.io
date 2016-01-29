/**
 * 页面ready方法
 */
$(document).ready(function() {

    categoryDisplay();
    generateContent();
    backToTop();
});

/**
 * load方法，页面的加载完成后触发
 * {fixFooterInit();} 固定Footer栏
 */
/*$(window).load(function() {
    fixFooterInit();
});*/


/**
 * 固定底栏的初始化方法
 * 在一开始载入页面时，使用fixFooter()方法固定底栏。
 * 在浏览器窗口改变大小是，依然固定底栏
 * @return {[type]} [description]
 */
function fixFooterInit() {
    var footerHeight = $('footer').outerHeight();
    var footerMarginTop = getFooterMarginTop() - 0; //类型转换
    // var footerMarginTop = 80;

    fixFooter(footerHeight, footerMarginTop); //fix footer at the beginning

    $(window).resize(function() { //when resize window, footer can auto get the postion
        fixFooter(footerHeight, footerMarginTop);
    });

    /*    $('body').click(function() {
        fixFooter(footerHeight, footerMarginTop);
    });*/


}

/**
 * 固定底栏
 * @param  {number} footerHeight    底栏高度
 * @param  {number} footerMarginTop 底栏MarginTop
 * @return {[type]}                 [description]
 */
function fixFooter(footerHeight, footerMarginTop) {
    var windowHeight = $(window).height();
    var contentHeight = $('body>.container').outerHeight() + $('body>.container').offset().top + footerHeight + footerMarginTop;
    // console.log("window---"+windowHeight);
    // console.log("$('body>.container').outerHeight()---"+$('body>.container').outerHeight() );
    // console.log("$('body>.container').height()---"+$('body>.container').height() );
    // console.log("$('#main').height()--------"+$('#main').height());
    // console.log("$('body').height()--------"+$('body').height());
    //console.log("$('#main').html()--------"+$('#main').html());
    // console.log("$('body>.container').offset().top----"+$('body>.container').offset().top);
    // console.log("footerHeight---"+footerHeight);
    // console.log("footerMarginTop---"+footerMarginTop);
    console.log(contentHeight);
    if (contentHeight < windowHeight) {
        $('footer').addClass('navbar-fixed-bottom');
    } else {
        $('footer').removeClass('navbar-fixed-bottom');
    }

    $('footer').show(400);
}

/**
 * 使用正则表达式得到底栏的MarginTop
 * @return {string} 底栏的MarginTop
 */
function getFooterMarginTop() {
    var margintop = $('footer').css('marginTop');
    var patt = new RegExp("[0-9]*");
    var re = patt.exec(margintop);
    // console.log(re[0]);
    return re[0];
}

/**
 * 分类展示
 * 点击右侧的分类展示时
 * 左侧的相关裂变展开或者收起
 * @return {[type]} [description]
 */
function categoryDisplay() {
    /*only show All*/
    $(".post-list-body>div[post-cate!=All]").hide();
    /*show category when click categories list*/
    $(".categories-list-item").click(function() {
        var cate = $(this).attr("cate"); //get tag's name

        $(".post-list-body>div[post-cate!=' + cate + ']").hide(250);
        $(".post-list-body>div[post-cate=' + cate + ']").show(400);
    });
}

/**
 * 回到顶部
 */
function backToTop() {
    //滚页面才显示返回顶部
    $(window).scroll(function() {
        if ($(window).scrollTop() > 100) {
            $("#top").fadeIn(500);
        } else {
            $("#top").fadeOut(500);
        }
    });
    //点击回到顶部
    $("#top").click(function() {
        $("body").animate({
            scrollTop: "0"
        }, 500);
    });

    //初始化tip
    $(function() {
        $('[data-toggle="tooltip"]').tooltip();
    });
}


/**
 * 侧边目录
 */
function generateContent() {

    // console.log($('#markdown-toc').html());
    if (typeof $('#markdown-toc').html() === 'undefined') {
        // $('#content .content-text').html('<ul><li>文本较短，暂无目录</li></ul>');
        $('#content').hide();
        $('#myArticle').removeClass('col-sm-9').addClass('col-sm-12');
    } else {
        $('#content .content-text').html('<ul>' + $('#markdown-toc').html() + '</ul>');
        /*   //数据加载完成后，加固定边栏
        $('#myAffix').attr({
            'data-spy': 'affix',
            'data-offset': '50'
        });*/
    }
    console.log("myAffix!!!");
}
/*加载单列瀑布流*/
window.onload=function(){

    var dataInt={'data':[{'src':'1.jpg'},{'src':'2.jpg'}]};
    
    window.onscroll=function(){
        if(checkscrollside()){
            var oParent = document.getElementById('post');// 父级对象
            for(var i=0;i<dataInt.data.length;i++){
                var oPin=document.createElement('div'); //添加 元素节点
                oPin.className='article';                   //添加 类名 name属性
                oParent.appendChild(oPin);              //添加 子节点
                var oBox=document.createElement('div');
                oBox.className='post-list-header';
				oBox.innerHTML="<h1>{{ page.title }}</h1> ";
                oPin.appendChild(oBox);
				
                //var oImg=document.createElement('img');
                //oImg.src='/image/'+dataInt.data[i].src;
               // oPin.appendChild(oImg);
            }
            
        };
    }
}



/****
    *通过父级和子元素的class类 获取该同类子元素的数组
    */
function getClassObj(parent,className){
    var obj=parent.getElementsByTagName('*');//获取 父级的所有子集
    var pinS=[];//创建一个数组 用于收集子元素
    for (var i=0;i<obj.length;i++) {//遍历子元素、判断类别、压入数组
        if (obj[i].className==className){
            pinS.push(obj[i]);
        }
    };
    return pinS;
} 
/****
    *获取 pin高度 最小值的索引index
    */
function getminHIndex(arr,minH){
    for(var i in arr){
        if(arr[i]==minH){
            return i;
        }
    }
}


function checkscrollside(){
    var oParent=document.getElementById('post');
    var aPin=getClassObj(oParent,'article');
    var lastPinH=aPin[aPin.length-1].offsetTop+Math.floor(aPin[aPin.length-1].offsetHeight/2);//创建【触发添加块框函数waterfall()】的高度：最后一个块框的距离网页顶部+自身高的一半(实现未滚到底就开始加载)
    var scrollTop=document.documentElement.scrollTop||document.body.scrollTop;//注意解决兼容性
    var documentH=document.documentElement.clientHeight;//页面高度
    return (lastPinH<scrollTop+documentH)?true:false;//到达指定高度后 返回true，触发waterfall()函数
}
