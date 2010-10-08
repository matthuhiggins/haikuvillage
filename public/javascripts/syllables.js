$.extend(String.prototype, {
  squish: function() {
    return $.strip(this.escapeHTML().replace(/\s+/g, ' '));
  },
  
  hash: function() {
    return '@' + this.replace(/^[^\w]+|[^\w]+$/g, '');
  }
});

function Word(text, syllables, state) {
  this.text = text;
  this.syllables = syllables;
  this.state = state;
}

Word.prototype = {
  encoded: function() {
    return encodeURIComponent(this.text).replace(/\-/g, '%2d');
  },  

  toElement: function() {
    var wordEl = document.createElement('span'),
        supEl = document.createElement('sup');

    $(supEl).text(this.syllables > -1 ? this.syllables : '?');
    $(wordEl).text(text).append(supEl);

    return wordEl;
  }
};

$.extend(Word, {
  COMPLETE    : 'complete',
  NEW         : 'new',
  REQUESTING  : 'requesting',
  RESPONDED   : 'responded',
  info        : {},
  
  fromText: function (text) {
    text = text.squish();
    return $.map(text.split(/ |\n/), function(value) {
      var word = Word.info[value.hash()];
      return word === undefined ? new Word(value, -1, Word.NEW) : new Word(value, word.syllables, word.state);
    });
  }
});

function Line(text, lineNumber) {
  this.words = Word.fromText(text);
  this.lineNumber = lineNumber;  
}

Line.prototype = {
  isCalculating: function() {
    return this.words.any(function(word){
      return word.syllables < 0;
    });
  },
  
  syllables: function() {
    var result = 0;
    $.each(this.words, function(i, word) {
      result += word.syllables;
    })
    return result;
  },
  
  isValid: function() {
    return (this.syllables() === 5 && (this.lineNumber === 0 || this.lineNumber === 2)) ||
           (this.syllables() === 7 && this.lineNumber === 1);
  },
  
  wordElements: function() {
    return $.map(this.words, function(word) {
      return word.toElement();
    });
  },

  toElement: function() {
    var div = document.createElement('div'),
        syllableEl = document.createElement('span'),
        textEl = document.createElement('span');

    $(syllables).addClass('syllables')
                .addClass(this.isValid() ? 'valid' : 'invalid')
                .text(this.isCalculating() ? '?' : this.syllables());

    
    $(textEl).appendChild(this.wordElements());
    
    $(div).addClass('line').append([syllableEl, textEl]);

    return div;
  }
};

function Haiku(text) {
  if ($.trim(text).length == '') {
    this.lines = [];
    return;
  }
  
  this.lines = text.split("\n").map(function(text, lineNumber) {
    return new Line(text, lineNumber);
  });
  
  if (this.lines.length > 3) {
    this.lines.length = 3;
  }
}

Haiku.prototype = {
  isValid: function() {
    return this.lines.length === 3 && this.lines.invoke('isValid').every();
  },

  toElements: function() {
    return $.map(this.lines, function(line) {
      return line.toElement();
    });
  }
};

Haiku.FormEvents = {
  BLANK_HAIKU_TEXT: "Write your haiku",
  
  limitTextArea: function(textArea) {
    $(textArea).keyup(function() {
      var lineText = $F(textArea).split(/\n/);
      if (lineText.length > 3) {
        lineText.length = 3;
        textArea.value = lineText.join('\n');
      }
    });
    
    $(textArea).keypress(function(e) {
      var lines = $(this).val().split(/\n/);

      if (e.keyCode === 13 && lines.length >= 3) {
        e.preventDefault();
      }
    }
  },
  
  haikuFieldFocus: function(field){
    if ( !field.value || field.value === Haiku.FormEvents.BLANK_HAIKU_TEXT ){
      field.removeClassName('empty');
      field.value = '';      
    }
  },
  
  haikuFieldBlur: function(field){
    if ( !field.value ){
      field.value = Haiku.FormEvents.BLANK_HAIKU_TEXT;
      field.addClassName('empty');
    }
  },
  
  clearEmptyOnFocus: function(field) {
    $(field).observe('focus', Haiku.FormEvents.haikuFieldFocus.curry(field));
    $(field).observe('blur', Haiku.FormEvents.haikuFieldBlur.curry(field));
  }
};

Haiku.PeriodicalUpdater = Class.create({
  initialize: function(textArea, previewElement, submitButton) {
    this.textArea = $(textArea);
    this.textArea.innerHTML = "Write your haiku";
    this.previewElement = $(previewElement);
    this.submitButton = $(submitButton);
    this.lastHaikuText = '';

    Haiku.FormEvents.limitTextArea(this.textArea);
    Haiku.FormEvents.clearEmptyOnFocus(this.textArea);
    Haiku.FormEvents.clearEmptyOnFocus(submitButton)
    this.start();
  },
  
  start: function() {
    this.timer = setInterval(this.updateHaiku.bind(this), 50);
  },
  
  requestWords: function(words) {
    var encodedWords = words.invoke('encoded').join('-');
    
    if (encodedWords.length === 0) {
      return;
    }
    
    var markRequesting = function(word) {
      Word.info[word.text.hash()].state = Word.REQUESTING;
    };
    
    var markResponded = function(word) {
      Word.info[word.text.hash()] = new Word(word.text, word.syllables, Word.RESPONDED);
    };
    
    words.each(markRequesting);
        
    var request = new Ajax.Request("/syllables?words=" + encodedWords, {
      method: 'get',
      onComplete: function(request) {
        request.responseText.evalJSON().each(markResponded);
      }
    });
  },
     
  updateHaiku: function() {
    if (this.textArea.hasClassName('empty')) {
      return;
    }

    var currentText = $F(this.textArea),
        currentWordArray = Word.fromText(currentText),
        currentHaiku = new Haiku(currentText);
        
    // Request words if they existed after two cycles
    var needsRequest = function(word) {
      return Word.info[word.text.hash()] && Word.info[word.text.hash()].state === Word.NEW;
    };
    
    this.requestWords(currentWordArray.findAll(needsRequest));

    // Add new new words
    Word.fromText(this.lastHaikuText).each(function(word) {
      Word.info[word.text.hash()] = Word.info[word.text.hash()] || word;
    });
    
    // Determine if anything changed. If not, don't update
    var somethingChanged = this.lastHaikuText !== currentText;
    for (var key in Word.info) if (Word.info.hasOwnProperty(key)) {
      if (Word.info[key].state === Word.RESPONDED) {
        somethingChanged = true;
        break;
      }
    }

    if (somethingChanged) {
      this.previewElement.innerHTML = currentHaiku.toHTML();
      $A(this.previewElement.getElementsByClassName(Word.RESPONDED)).invoke('highlight');
      this.previewElement.removeClassName('empty');
    }
    
    for (var key in Word.info) if (Word.info.hasOwnProperty(key)) {
      var word = Word.info[key];
      if (word.state === Word.RESPONDED) {
        word.state = Word.COMPLETE;
      }
    }

    this.submitButton.disabled = !currentHaiku.isValid();
    this.lastHaikuText = currentText;
  }
});