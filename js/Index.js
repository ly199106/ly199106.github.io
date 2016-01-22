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

