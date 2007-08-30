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

function findElementById(responseText, div_id) {
    var div = document.createElement('div');
    div.innerHTML = responseText;
    var finder = function(el) {
        return el.id && el.id == div_id;
    }
    var newElements = YAHOO.util.Dom.getElementsBy(finder, 'div', div);
    if (newElements.length > 0) {
        return newElements[0].innerHTML;
    } else {
        return null;
    }
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

    YAHOO.util.Dom.get("haiku_center").innerHTML = newFragment;
    YAHOO.util.Dom.get("pagination").innerHTML = newPagination;
    var anim = new YAHOO.util.Anim('haiku_hidden', attributes, 1, YAHOO.util.Easing.easeOut);
    anim.animate();
}