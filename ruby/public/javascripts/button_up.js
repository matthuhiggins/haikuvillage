Village = {};
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
    }
};

YAHOO.util.Event.addListener(window, "load", Village.Buttons.makeYui);