//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You CANNOT use CoffeeScript in this file - because it's JavaScript!

$(document).ready(function() {
    $('input.datetimepicker').click(function() {
        $(this).datetimepicker('show');
    }).datetimepicker({
        format: 'm/d/y  g:i a',
        formatTime: 'g:i a',
        step: 15,
        startDate: new Date()
    });

    var actualEndDateField = $('#end_date');
    var placeholderText = actualEndDateField.attr('placeholder');
    actualEndDateField.click(function() {
        if ($(this).val().trim() == '') {
            $(this).attr('placeholder', placeholderText);
        } else {
            $(this).attr('placeholder', '');
        }
    });
});