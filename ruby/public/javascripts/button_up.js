Village.Buttons = {    
    registry: {},
    registeredClassNames: {},
    
	makeYui: function() {
	    var inputButtons = YAHOO.util.Dom.getElementsBy(function(element){
            return ((element.tagName == 'BUTTON') ||
                ((element.tagName == 'INPUT') && (element.type in set('submit', 'reset', 'button')))) &&
                !YAHOO.util.Dom.hasClass(element.parentNode, 'first-child');
        });
  
        YAHOO.util.Dom.generateId(inputButtons);
        for(var i = 0; i < inputButtons.length; i++) {
  	        var isDisabled = false;
            var originalId = inputButtons[i].id;
            var onClickFn = null;
            for(className in Village.Buttons.registeredClassNames) {
                if (YAHOO.util.Dom.hasClass(inputButtons[i], className)) {
                    onClickFn = Village.Buttons.registeredClassNames[className];
                    break;
                }                
            }
            button = new YAHOO.widget.Button(inputButtons[i].id, {disabled: isDisabled});
            if (onClickFn) {
                button.addListener('click', onClickFn, originalId);
            }
            Village.Buttons.registry[originalId] = button;
                
        }
    },
	
	haikuFlyOver: function() {
		function handleMouseOverOut(e, haikuDiv) {
			var stuff = YAHOO.util.Dom.getElementsByClassName('add_to_favorites', 'p', haikuDiv);
			for(var i = 0; i < stuff.length; i++) {
				var newOpacity = e.type === 'mouseover' ? 1 : 0;				
				var anim = new YAHOO.util.Anim(stuff[i], { opacity: { to: newOpacity } }, 1.0, YAHOO.util.Easing.easeOut);
				anim.animate();
			}
		}
		
		var haikuDivs = YAHOO.util.Dom.getElementsByClassName('haiku');
		for(var i = 0; i < haikuDivs.length; i++) {
			YAHOO.util.Event.addListener(haikuDivs[i], "mouseover", handleMouseOverOut, haikuDivs[i]);
			YAHOO.util.Event.addListener(haikuDivs[i], "mouseout", handleMouseOverOut, haikuDivs[i]);			
		}
	},
	
	registerClassOnClick: function(className, fn) {
	    Village.Buttons.registeredClassNames[className] = fn;
	}
};

Village.util.registerWithHaikuRefresh(Village.Buttons.makeYui);
Village.util.registerWithHaikuRefresh(Village.Buttons.haikuFlyOver);

Village.Buttons.registerClassOnClick('favorites_button', function(eventType, buttonId) {    
    var buttonObj = Village.Buttons.registry[buttonId];
    var buttonEl = getEl(buttonId);    
    var action = buttonObj.get('name');
    
    buttonObj.set("disabled", true);
    buttonObj.set("label", 'Adding...');
    
    var haiku = YAHOO.util.Dom.getAncestorByClassName (buttonEl, 'haiku');
    haiku_id = haiku.id.replace("haiku_", "");
    new Ajax.Request("/my_haiku/" + action + "_favorite/" + haiku_id, {
        method: "post",
        onComplete: function() {
            buttonEl.parentNode.innerHTML = "You love it.";
    }});
});