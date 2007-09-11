function object(o) {
  function F() {}
  F.prototype = o;
  return new F();
}

function set() {
  var result = {};
  for (var i = 0; i < arguments.length; i++)
    result[arguments[i]] = true;
  return result;
}

function createDomFromText(text) {
	var div = document.createElement('div');
	div.innerHTML = text;
	return YAHOO.util.Dom.getFirstChild(div);
}

function getEl(element) {
  if (typeof element == 'string')
    element = document.getElementById(element);
  return element;
}

function getElementInText(text, div_id) {
    var div = document.createElement('div');
    div.innerHTML = text;
    var newElements = YAHOO.util.Dom.getElementsBy(function(el) {
            return el.id && el.id == div_id;
        }, 'div', div);
	
	return newElements.length > 0 ? newElements[0] : null;
}

function paginate(request, isNext) {
	var start = isNext ? 0 : '-600px';
	var attributes = { 'margin-left': { to: -300 } };

    var newFragment = getElementInText(request.responseText, "haiku_center");
    var newPagination = getElementInText(request.responseText, "pagination");

	original = getEl("haiku_center").innerHTML;
	getEl("haiku_left").innerHTML = original;
	getEl("haiku_right").innerHTML = original;
    YAHOO.util.Dom.setStyle("haiku_hidden", 'margin-left', start);

    getEl("haiku_center").innerHTML = newFragment.innerHTML;
    getEl("pagination").innerHTML = newPagination.innerHTML;
    var anim = new YAHOO.util.Anim('haiku_hidden', attributes, 0.6, YAHOO.util.Easing.easeOut);
    anim.animate();
}

function addHaiku(text) {
    var haikuList = getEl("haiku_box");
	
    var fadeIn = function () {
		var newHaikuDiv = createDomFromText(text);
				
		YAHOO.util.Dom.setStyle(newHaikuDiv, 'color', '#fff');
		haikuList.replaceChild(newHaikuDiv, emptyHaikuDiv);
		var colorAttributes = {
			color: { from: '#fff', to:'#000' }
		};
		
		var colorAnim = new YAHOO.util.ColorAnim(newHaikuDiv.id, colorAttributes, 0.5, YAHOO.util.Easing.easeOut);
		colorAnim.animate();		
	    if (YAHOO.util.Dom.getChildren(haikuList).length > 4) {
            haikuList.removeChild(YAHOO.util.Dom.getLastChild(haikuList));
		}
	}
		
	var emptyHaikuDiv = createDomFromText("<div class='haiku' id='empty_haiku'>&nbsp;</div>");
	if (YAHOO.util.Dom.getChildren(haikuList).length === 0) {
		haikuList.appendChild(emptyHaikuDiv);
		emptyHaikuDiv = getEl("empty_haiku");
		fadeIn();
    } else {	   
	    YAHOO.util.Dom.setStyle(emptyHaikuDiv, 'margin-top', '-90px');	
	    emptyHaikuDiv = YAHOO.util.Dom.insertBefore(emptyHaikuDiv, YAHOO.util.Dom.getFirstChild(haikuList));
        var scrollAnim = new YAHOO.util.Anim(emptyHaikuDiv, {'margin-top': { from: -90, to: 0 }}, 0.3, YAHOO.util.Easing.easeOut);
	    scrollAnim.onComplete.subscribe(fadeIn);
	    scrollAnim.animate();
    }
}