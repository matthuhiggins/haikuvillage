Village.Login = {
    swapButtonsAnim: function(oldButtons, newButtons, tweenAnim) {
      function showNewButtons() {
          var showButtons = new YAHOO.util.Anim(newButtons, { 'left': { to: 0 } }, 0.5, YAHOO.util.Easing.easeOut);        
          showButtons.animate();          
      }
      var hideOldButtons = new YAHOO.util.Anim(oldButtons, { 'left': { to: -200 } }, 0.2, YAHOO.util.Easing.easeIn);
      hideOldButtons.onComplete.subscribe(tweenAnim);
      tweenAnim.onComplete.subscribe(showNewButtons);
      return hideOldButtons;
    },
    
    hideRegistration: function() {
        getEl('user_email').focus();
        var swapAnim = Village.Login.swapButtonsAnim('register-buttons', 'login-buttons');
        swapAnim.animate();
    },
    
    showRegistration: function () {
        function showLabels(eventTyp, args, scope) {
            var labels = scope.getElementsByTagName('label');
            for(var i = 0; i < labels.length; i++) {
                YAHOO.util.Dom.setStyle(labels[i], 'visibility', 'visible');
            }
        }
                
        function showRegisterBoxes() {
            function showRegisterBox(id, attributes) {
                var object = getEl(id);
                YAHOO.util.Dom.setStyle(object, 'visibility', 'visible');
                var animation = new YAHOO.util.Anim(object, attributes, 0.2); 
                animation.onComplete.subscribe(showLabels, object);
                animation.animate();
                return animation;
            }

            showRegisterBox('password_confirmation_box', { 'margin-top': { to: 0 } });
            return showRegisterBox('alias_box', { 'margin-bottom': { to: 0 } });    
        }
        
        getEl('user_alias').focus();
        var loginOutAnim = Village.Login.swapButtonsAnim('login-buttons', 'register-buttons', showRegisterBoxes());
        loginOutAnim.animate();
    }
};

YAHOO.util.Event.addListener('sign_up', "click", Village.Login.showRegistration);

YAHOO.util.Event.addListener(window, "load", function() {
    Village.Buttons.registry["register_cancel"].addListener('click', Village.Login.hideRegistration); 
});
