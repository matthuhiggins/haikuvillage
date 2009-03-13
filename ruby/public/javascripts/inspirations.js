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
  
  function setupFlickr() {
    $('inspiration_preview').show();
    $('cancel_line').show();
    $('inspiration_what').hide();
    $('inspiration_selection').hide();
    displayCurrent();
  }
  
  function setupUpload(){
    $('cancel_line').show();
    $('inspiration_upload').show();
    $('inspiration_what').hide();
    $('inspiration_selection').hide();
  }
  
  preCacheImages();

  $('use_flickr').observe('click', function(event) {
    Event.stop(event);
    setupFlickr();
  });
  
  $('use_upload').observe('click', function(event) {
    Event.stop(event);
    setupUpload();
  })

  $('prev_inspiration').observe('click', function(event) {
    Event.stop(event);
    index = index-- < 0 ? (inspirations.length - 1) : index;
    displayCurrent();
  });
  
  $('next_inspiration').observe('click', function(event) {
    Event.stop(event);
    index = (index + 1) % inspirations.length;
    displayCurrent();
  });
  
  $('cancel_link').observe('click', function(event) {
    Event.stop(event);
    $("upload_inspiration_image").innerHTML = "";
    $('conversation_id_wrapper').innerHTML = "";
    $('inspiration_image').innerHTML = "";
    $('inspiration_upload').hide();
    $('inspiration_preview').hide();
    $('cancel_line').hide();
    $('inspiration_what').show();
    $('inspiration_selection').show();
  });
};

function showUpload(conversation_id, url){
  $("upload_inspiration_image").innerHTML = "<img id='inspiration' src='" + url + "' />";
  $('conversation_id_wrapper').innerHTML = "<input type=\"hidden\" name=\"haiku[conversation_id]\" value=\"" + conversation_id + "\" />";
  $("inspiration_upload").hide();
}