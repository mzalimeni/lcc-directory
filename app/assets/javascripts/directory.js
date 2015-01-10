//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You CANNOT use CoffeeScript in this file - because it's JavaScript!

$(document).ready(function() {
    var searchButton = $('#directory-search-button');
    var searchField = $('#query');
    searchField.keyup(function() {
        if(searchField.val().trim() == "") {
            searchButton.val('Browse');
        } else {
            searchButton.val('Search');
        }
    });
});