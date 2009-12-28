if(navigator.userAgent.indexOf("MSIE 6") >= 0) {
  window.location = "http://www.mozilla.com/firefox/";
}

document.observe("dom:loaded", function() {
  $('haiku_search').observe('focus', function() {
    this.value = '';
  });
});