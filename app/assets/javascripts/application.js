//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require_tree .

$(function() {
  $('#haiku_search').hintInput();

  $('#logout-link').click(function(e) {
    if (FB.getAuthResponse()) {
      e.preventDefault();
      var path = $(this).attr('href');
      FB.logout(function() {
        window.location = path;
      });
    }
  });
  
  $("#haiku_subject_name").autocomplete({
    minLength: 2,
    source: "autocomplete/subject.js",
    dataType: "json"
  });
});