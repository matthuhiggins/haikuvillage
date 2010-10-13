window.inspirations = function(inspirations) {
  var index = Math.floor(inspirations.length * Math.random());
  
  function preCacheImages() {
    $.each(inspirations, function(i, inspiration) {
      var i = new Image();
      i.src = inspiration.thumbnail;
    });
  }
  
  function displayCurrent() {
    var inspiration = inspirations[index],  
        image = document.createElement('img'),
        input = document.createElement('input');
    
    $(image).attr('src', inspiration.thumbnail);
    $(input).attr({'type': 'hidden', 'name': 'haiku[conversation_id]', 'value': inspiration.id});
    
    $('#inspiration_image').empty().append(image);
    $('#conversation_id_wrapper').empty().append(input);
  }
  
  function setupFlickr() {
    $('#inspiration_preview').show();
    $('#cancel_line').show();
    $('#inspiration_what').hide();
    $('#inspiration_selection').hide();
    displayCurrent();
  }
  
  preCacheImages();

  $('#use_flickr').click(function(e) {
    e.preventDefault();
    setupFlickr();
  });

  $('#prev_inspiration').click(function(e) {
    e.preventDefault();
    if (index == 0) {
      index = inspirations.length - 1;
    } else {
      index--;
    }
    displayCurrent();
  });
  
  $('#next_inspiration').click(function(e) {
    e.preventDefault();
    index = (index + 1) % inspirations.length;
    displayCurrent();
  });
  
  $('#cancel_link').click(function(e) {
    e.preventDefault();
    $('#conversation_id_wrapper').empty();
    $('#inspiration_image').empty();
    $('#inspiration_upload').hide();
    $('#inspiration_preview').hide();
    $('#cancel_line').hide();
    $('#inspiration_what').show();
    $('#inspiration_selection').show();
  });
};

function showUpload(conversation_id, url){
  $('conversation_id_wrapper').innerHTML = "<input type=\"hidden\" name=\"haiku[conversation_id]\" value=\"" + conversation_id + "\" />";
  $("inspiration_upload").hide();
}