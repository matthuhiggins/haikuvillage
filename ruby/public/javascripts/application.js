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

function getEl(element) {
  if (typeof element == 'string')
    element = document.getElementById(element);
  return element;
}

function findElementById(responseText, div_id) {
    var div = document.createElement('div');
    div.innerHTML = responseText;
    var newElements = YAHOO.util.Dom.getElementsBy(function(el) {
            return el.id && el.id == div_id;
        }, 'div', div);
	
	return newElements.length > 0 ? newElements[0] : null;
}

function paginate(request, isNext) {
	var start = isNext ? 0 : '-1200px';
	var attributes = { 'margin-left': { to: -600 } };

    var newFragment = findElementById(request.responseText, "haiku_center");
    var newPagination = findElementById(request.responseText, "pagination");

	original = YAHOO.util.Dom.get("haiku_center").innerHTML;
	YAHOO.util.Dom.get("haiku_left").innerHTML = original;
	YAHOO.util.Dom.get("haiku_right").innerHTML = original;
    YAHOO.util.Dom.setStyle("haiku_hidden", 'margin-left', start);

    YAHOO.util.Dom.get("haiku_center").innerHTML = newFragment.innerHTML;
    YAHOO.util.Dom.get("pagination").innerHTML = newPagination.innerHTML;
    var anim = new YAHOO.util.Anim('haiku_hidden', attributes, 0.6, YAHOO.util.Easing.easeOut);
    anim.animate();
}