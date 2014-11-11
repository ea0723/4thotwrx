$(document).ready(function() {
    $('.sourcelink').click(function() {
        $('#destination').val($(this).html());
    });
});