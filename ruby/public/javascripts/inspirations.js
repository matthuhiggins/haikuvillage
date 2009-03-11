window.inspirations = function(inspirations) {
  var index = Math.floor(inspirations.length * Math.random());
  
  function preCacheImages() {
    inspirations.each(function(inspiration) { var i = new Image(); i.src = inspiration.thumbnail; });
  }
  
  function displayCurrent() {
    var inspiration = inspirations[index];
    $('inspiration_image').innerHTML = "<img src=\"" + inspiration.thumbnail + "\" />";
    $('conversation_id_wrapper').innerHTML = "<input type=\"hidden\" name=\"haiku[conversation_id]\" value=\"" + inspiration.id + "\" />";
  }
  
  function setupCheckBox() {
    var checkbox = $('use_inspiration');
    if (checkbox.checked) {
      $('inspiration_preview').setStyle({'display': 'block'});
      $('inspiration_what').setStyle({'display': 'none'});
      displayCurrent();
    } else {
      $('inspiration_preview').setStyle({'display': 'none'});
      $('inspiration_image').innerHTML = "";
      $('inspiration_what').setStyle({'display': 'block'});
    }
  }
  
  preCacheImages();
  setupCheckBox();

  $('use_inspiration').observe('click', function() {
    setupCheckBox();
  })

  $('prev_inspiration').observe('click', function() {
    index = index-- < 0 ? (inspirations.length - 1) : index;
    displayCurrent();
  });
  
  $('next_inspiration').observe('click', function() {
    index = (index + 1) % inspirations.length;
    displayCurrent();
  });
};