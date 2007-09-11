Village.Buttons = {    
    buttonRegistry: {},
    
	makeYui: function() {
	    var inputButtons = YAHOO.util.Dom.getElementsBy(function(element){
            return (element.tagName == 'BUTTON') ||
                ((element.tagName == 'INPUT') && (element.type in set('submit', 'reset', 'button')));
        });
  
        YAHOO.util.Dom.generateId(inputButtons);
        for(var i = 0; i < inputButtons.length; i++) {
  	        isDisabled = false;//YAHOO.util.Dom.hasClass(inputButtons[i].id, 'disabled');
            originalId = inputButtons[i].id;
            Village.Buttons.buttonRegistry[originalId] =
                new YAHOO.widget.Button(inputButtons[i].id, {disabled: isDisabled});
        }
    },
	
	haikuFlyOver: function() {
		function handleMouseOverOut(e, haikuDiv) {
			//alert(haikuDiv.id);
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
	}
};

YAHOO.util.Event.addListener(window, "load", Village.Buttons.makeYui);
YAHOO.util.Event.addListener(window, "load", Village.Buttons.haikuFlyOver);