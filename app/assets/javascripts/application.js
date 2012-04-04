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
});