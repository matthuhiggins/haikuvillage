(function($){
  $.fn.hintInput = function() {  
    return this.each(function() {
      var input = $(this),
          originalValue = input.val();

      input.focus(function() {
        if (input.hasClass('empty')) {
          input.val('').removeClass('empty');
        }
      });

      input.blur(function() {
        if ($.trim(input.val()) == '') {
          input.val(originalValue).addClass('empty');
        }
      });
    });
  };
})( jQuery );