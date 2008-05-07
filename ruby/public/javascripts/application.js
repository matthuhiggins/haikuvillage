document.observe("dom:loaded", function() {
  $('login_link').observe('click', function(event){
    Effect.toggle('login_form', 'appear');
   });
});