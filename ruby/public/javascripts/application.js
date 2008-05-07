document.observe("dom:loaded", function() {
  $('login_link').onclick = function(event){
    Effect.toggle('login_form', 'appear');
    return false;
   };
});