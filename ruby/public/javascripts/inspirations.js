window.inspirations = function(inspirations) {
  var index = Math.floor(inspirations.length * Math.random());
  
  function preCacheImages() {
    inspirations.each(function(inspiration) { var i = new Image(); i.src = inspiration.thumbnail; });
  }
  
  function displayCurrent() {
    var inspiration = inspirations[index];
    $('inspiration_preview').innerHTML = "<img src=\"" + inspiration.thumbnail + "\" />";
    $('inspiration_preview').innerHTML += "<input type=\"hidden\" name=\"haiku[conversation_id]\" value=\"" + inspiration.id + "\" />";
  }
  
  displayCurrent();
  preCacheImages();

  $('prev_inspiration').observe('click', function() {
    index--;
    index = index < 0 ? (inspirations.length - 1) : index;
    displayCurrent();
  });
  
  $('next_inspiration').observe('click', function() {
    index = (index + 1) % inspirations.length;
    displayCurrent();
  });
};