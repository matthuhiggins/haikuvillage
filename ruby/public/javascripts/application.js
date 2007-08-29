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

function paginate(request, isNext) {
	var oldDom = isNext ? 'haiku_left' : 'haiku_right';
	var start = isNext ? 0 : -600
	var attributes = { 'margin-left': { from: start, to : -300 } };

	original = YAHOO.util.Dom.get("haiku_center").innerHTML;
	YAHOO.util.Dom.get("paginated_haikus").innerHTML = request.responseText;
	YAHOO.util.Dom.get(oldDom).innerHTML = original;
    var anim = new YAHOO.util.Anim('haiku_hidden', attributes, 1, YAHOO.util.Easing.easeOut);
    anim.animate();
}