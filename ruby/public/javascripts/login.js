Village.Login = {
    hideRegistration: function() {
        alert("not implemented")
    },
    
    showRegistration: function () {
        function showLabels(eventTyp, args, scope) {
            var labels = scope.getElementsByTagName('label');
            for(var i = 0; i < labels.length; i++) {
                YAHOO.util.Dom.setStyle(labels[i], 'visibility', 'visible');
            }
        }
        
        function showRegisterButtons() {
            var showButtons = new YAHOO.util.Anim('register-buttons', { 'left': { to: 0 } }, 0.5, YAHOO.util.Easing.easeOut);        
            showButtons.animate();
        }
        
        function showRegisterBoxes() {
            function showRegisterBox(id, attributes) {
                var object = getEl(id);
                YAHOO.util.Dom.setStyle(object, 'visibility', 'visible');
                var animation = new YAHOO.util.Anim(object, attributes, 0.2); 
                animation.onComplete.subscribe(showLabels, object)
                animation.animate();
            }

            showRegisterBox('password_confirmation_box', { 'margin-top': { to: 0 } });
            showRegisterBox('alias_box', { 'margin-bottom': { to: 0 } });    
        }
        
        getEl('user_alias').focus();
        var loginOut = new YAHOO.util.Anim('login-buttons', { 'left': { to: -200 } }, 0.2, YAHOO.util.Easing.easeIn);        
        loginOut.onComplete.subscribe(showRegisterBoxes);
        loginOut.onComplete.subscribe(showRegisterButtons);
        
        loginOut.animate();
    }
};

YAHOO.util.Event.addListener('sign_up', "click", Village.Login.showRegistration);

YAHOO.util.Event.addListener(window, "load", function() {
    Village.Buttons.buttonRegistry["register_cancel"].addListener('click', Village.Login.hideRegistration); 
});
