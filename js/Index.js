/**
 * �ص�����
 */
function backToTop() {
    //��ҳ�����ʾ���ض���
    $(window).scroll(function() {
        if ($(window).scrollTop() > 100) {
            $("#top").fadeIn(500);
        } else {
            $("#top").fadeOut(500);
        }
    });
    //����ص�����
    $("#top").click(function() {
        $("body").animate({
            scrollTop: "0"
        }, 500);
    });

    //��ʼ��tip
    $(function() {
        $('[data-toggle="tooltip"]').tooltip();
    });
}

