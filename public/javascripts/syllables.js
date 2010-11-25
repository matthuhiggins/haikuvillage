$.extend(String.prototype, {
  squish: function() {
    // if (this.length == 0) {
    //   return '';
    // }
    // var escapedHtml = $(document.createElement('span')).text(this).html();
    return $.trim(this.replace(/\s+/g, ' '));
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
    $(wordEl).text(this.text).append(supEl).addClass(this.state).addClass('word');

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
    var result = false;
    $.each(this.words, function(i, word) {
      result = result || (word.syllables < 0);
    });
    return result;
  },
  
  syllables: function() {
    var result = 0;
    $.each(this.words, function(i, word) {
      if (word.syllables > 0) {
        result += word.syllables;
      }      
    });
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

    $(syllableEl).addClass('syllables')
                 .addClass(this.isValid() ? 'valid' : 'invalid')
                 .text(this.syllables());

    
    $(textEl).append(this.wordElements());
    
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
    var result = this.lines.length === 3;

    $.each(this.lines, function(i, line) {
      result = result && line.isValid();
    });
    
    return result;
  },

  toElements: function() {
    return $.map(this.lines, function(line) {
      return line.toElement();
    });
  }
};

Haiku.FormEvents = {
  limitTextArea: function(textArea) {
    textArea.keyup(function() {
      var lines = textArea.val().split(/\n/);

      if (lines.length > 3) {
        lines.length = 3;
        textArea.val(lines.join('\n'));
      }
    });
    
    textArea.keypress(function(e) {
      var lines = textArea.val().split(/\n/);

      if (e.keyCode === 13 && lines.length >= 3) {
        e.preventDefault();
      }
    });
  }
};

Haiku.PeriodicalUpdater = function(textArea, previewElement, submitButton) {
  this.textArea = $(textArea).hintInput();
  this.previewElement = $(previewElement);
  this.submitButton = $(submitButton);
  this.lastHaikuText = '';

  Haiku.FormEvents.limitTextArea(this.textArea);
  this.start();
};

Haiku.PeriodicalUpdater.prototype = {
  start: function() {
    var self = this;
    this.timer = setInterval(function() {
      self.updateHaiku.call(self);
    }, 50);
  },
  
  requestWords: function(words) {
    var encodedWords = $.map(words, function(word) {
      return word.encoded();
    }).join('-');
    
    if (encodedWords.length === 0) {
      return;
    }

    $.each(words, function(i, word) {
      Word.info[word.text.hash()].state = Word.REQUESTING;
    });

    var request = $.getJSON("/syllables?words=" + encodedWords, function(wordCounts) {
      $.each(wordCounts, function(i, wordCount) {
        Word.info[wordCount.text.hash()] = new Word(wordCount.text, wordCount.syllables, Word.RESPONDED);
      });
    });
  },
     
  updateHaiku: function() {
    if (this.textArea.hasClass('empty')) {
      return;
    }

    var currentText = this.textArea.val(),
        currentWordArray = Word.fromText(currentText),
        currentHaiku = new Haiku(currentText);
        
    // Request words if they exist after two cycles
    var needsRequest = function(word) {
      return 
    };

    var wordsNeedingRequest = [];
    $.each(currentWordArray, function(i, word) {
      if (Word.info[word.text.hash()] && Word.info[word.text.hash()].state === Word.NEW) {
        wordsNeedingRequest.push(word);
      }
    });
    this.requestWords(wordsNeedingRequest);

    // Add new words
    $.each(Word.fromText(this.lastHaikuText), function(i, word) {
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
      this.previewElement.empty()
                         .removeClass('empty')
                         .append(currentHaiku.toElements())
                         .find('.responded').css('background-color', '#ffff99').animate({'background-color': '#ffffff'});
    }
    
    for (var key in Word.info) if (Word.info.hasOwnProperty(key)) {
      var word = Word.info[key];
      if (word.state === Word.RESPONDED) {
        word.state = Word.COMPLETE;
      }
    }

    this.submitButton.button(currentHaiku.isValid() ? 'enable' : 'disable');
    this.lastHaikuText = currentText;
  }
};