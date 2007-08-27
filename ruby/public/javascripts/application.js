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