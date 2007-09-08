Village.Login = {
    hideRegistration: function() {
        
    },
    
    showRegistration: function () {
        function showLabels(eventTyp, args, scope) {
            var labels = scope.getElementsByTagName('label');
            for(var i = 0; i < labels.length; i++) {
                YAHOO.util.Dom.setStyle(labels[i], 'visibility', 'visible');
            }
            showRegisterButtons();
        }
        
        function showRegisterButtons() {
            var anim2 = new YAHOO.util.Anim('register-buttons', { 'left': { to: 0 } }, 0.5, YAHOO.util.Easing.easeOut);        
            anim2.animate();
        }
        
        function animateInputBoxes() {
            function animateInputBox(id, attributes) {
                var object = getEl(id);
                YAHOO.util.Dom.setStyle(object, 'visibility', 'visible');
                var animation = new YAHOO.util.Anim(object, attributes, 0.2); 
                animation.onComplete.subscribe(showLabels, object)
                animation.animate();
            }

            animateInputBox('password_confirmation_box', { 'margin-top': { to: 0 } });
            animateInputBox('useralias_box', { 'margin-bottom': { to: 0 } });    
        }
        
        getEl('useralias').focus();
        var loginOut = new YAHOO.util.Anim('login-buttons', { 'left': { to: -200 } }, 0.5, YAHOO.util.Easing.easeIn);        
        loginOut.onComplete.subscribe(animateInputBoxes);
        loginOut.animate();
    }
};

YAHOO.util.Event.addListener('sign_up', "click", Village.Login.showRegistration);

YAHOO.util.Event.addListener(window, "load", function() {
    Village.Buttons.buttonRegistry["register_cancel"].addListener('click', Village.Login.hideRegistration); 
});
