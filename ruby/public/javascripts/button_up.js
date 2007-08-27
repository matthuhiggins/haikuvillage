makeYuiButtons = function initializeButtons() {
  inputButtons = YAHOO.util.Dom.getElementsBy(function(element){
    return (element.tagName == 'INPUT') && (element.type in set('submit', 'reset', 'button'));
  });
  
  YAHOO.util.Dom.generateId(inputButtons);
  for(var i = 0; i < inputButtons.length; i++) {
    new YAHOO.widget.Button(inputButtons[i].id);
  }
}

YAHOO.util.Event.addListener(window, "load", makeYuiButtons);