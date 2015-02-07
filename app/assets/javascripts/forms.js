//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You CANNOT use CoffeeScript in this file - because it's JavaScript!

$(document).ready(function() {
    $(".form-group select").each(function() {
        $(this).select2();
    });
});

$(document).ready(function() {
    $('input.datepicker').click(function() {
        $(this).datetimepicker('show');
    }).datetimepicker({
        format: 'm/d',
        startDate: new Date(),
        timepicker: false,
        onShow: function() {
            $(".xdsoft_label.xdsoft_year").hide();
        }
    });

    var actualBirthdayField = $('#birthday');
    var placeholderText = actualBirthdayField.attr('placeholder');
    actualBirthdayField.click(function() {
        if ($(this).val().trim() == '') {
            $(this).attr('placeholder', placeholderText);
        } else {
            $(this).attr('placeholder', '');
        }
    });
});