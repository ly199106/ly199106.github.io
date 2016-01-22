/**
 * Ò³Ãæready·½·¨
 */
$(document).ready(function() {

    categoryDisplay();
    generateContent();
    backToTop();
});
/**
 * back to the top
 */
function backToTop() {
    //Scroll to back to the top
    $(window).scroll(function() {
        if ($(window).scrollTop() > 100) {
            $("#top").fadeIn(500);
        } else {
            $("#top").fadeOut(500);
        }
    });
    //Click to roll back to the top
    $("#top").click(function() {
        $("body").animate({
            scrollTop: "0"
        }, 500);
    });

    //Initialize tip
    $(function() {
        $('[data-toggle="tooltip"]').tooltip();
    });
}

