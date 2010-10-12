if(navigator.userAgent.indexOf("MSIE 6") >= 0) {
  window.location = "http://www.mozilla.com/firefox/";
}

$(function() {
  $('#haiku_search').hintInput();

  $('#logout-link').click(function(e) {
    e.preventDefault();
    var path = $(this).attr('href');
    FB.logout(function() {
      window.location = path;
    });
  });
});