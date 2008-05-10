document.observe("dom:loaded", function() {
  var loginLink = $('login_link');
  if (loginLink) {
    loginLink.onclick = function(event) {
      Effect.toggle('login_form', 'appear');
      return false;
     };
  }
  
  var show_haiku_login = $('show_haiku_login');
  if (show_haiku_login) {
    Event.observe(show_haiku_login, 'click', function() {
      show_haiku_login.setStyle({display: 'none'})
      Effect.Appear('haiku_login');
    });
  }
});