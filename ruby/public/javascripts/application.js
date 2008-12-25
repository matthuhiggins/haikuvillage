document.observe("dom:loaded", function() {
  $('haiku_search').observe('focus', function() {
    this.value = '';
  });
});