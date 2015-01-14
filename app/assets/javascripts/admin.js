//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You CANNOT use CoffeeScript in this file - because it's JavaScript!

$(document).ready(function() {
    $('input.datetimepicker').click(function() {
        $(this).datetimepicker('show');
    }).datetimepicker({
        format: 'm/d/y  g:i a',
        formatTime: 'g:i a',
        step: 15
    });
});