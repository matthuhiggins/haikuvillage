Village = {};
Village.Buttons = {
	makeYui: function() {
	    inputButtons = YAHOO.util.Dom.getElementsBy(function(element){
            return (element.tagName == 'INPUT') && (element.type in set('submit', 'reset', 'button'));
        });
  
        YAHOO.util.Dom.generateId(inputButtons);
        for(var i = 0; i < inputButtons.length; i++) {
  	        isDisabled = false;//YAHOO.util.Dom.hasClass(inputButtons[i].id, 'disabled');
            new YAHOO.widget.Button(inputButtons[i].id, {disabled: isDisabled});
        }
    }
};

YAHOO.util.Event.addListener(window, "load", Village.Buttons.makeYui);