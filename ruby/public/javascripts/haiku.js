Object.extend(String.prototype, {
  squish: function() {
    return this.escapeHTML().replace(/\n +/, '\n').replace(/ +/g, ' ').strip();  
  },
  
  hash: function() {
    return '@' + this.replace(/^[^\w]|[^\w]$/, '');
  }
});

var Word = Class.create();
Object.extend(Word, {
  COMPLETE    : 'complete',
  NEW         : 'new',
  REQUESTING  : 'requesting',
  RESPONDED   : 'responded',
  info        : {},
  
  fromText: function (text) {
    text = text.squish();
    return $A(text.split(/ |\n/)).map(function(value) {
      var word = Word.info[value.hash()];
      return word === undefined ? new Word(value, -1, Word.NEW) : new Word(value, word.syllables, word.state);
    });
  }
});

Word.prototype = {
  initialize: function(text, syllables, state) {
    this.text = text;
    this.syllables = syllables;
    this.state = state;
  },
  
  encoded: function(){
    return encodeURIComponent(this.text.replace(/\./g, '%2e').replace(/\-/g, '%2d'));
  },  

  toHTML: function(){
    return "<span class=#{state}>#{text}<sup>#{syllables}</sup></span>".interpolate({
      state: this.state,
      text: this.text,
      syllables: this.syllables > -1 ? this.syllables : '?'
    });
  }
};

var Line = Class.create();
Line.prototype = {
  initialize: function(text, line_number) {
    this.words = Word.fromText(text);
    this.line_number = line_number;
  },

  isCalculating: function(){
    return this.words.any(function(word){
      return word.syllables < 0;
    });
  },
  
  syllables: function(){
    return eval(this.words.map(function(word){
      return word.syllables;
    }).join("+"));
  },
  
  isValid: function(){
    return (this.syllables() === 5 && (this.line_number === 0 || this.line_number === 2)) ||
           (this.syllables() === 7 && this.line_number === 1);
  },
    
  toHTML: function(){
    return "<div><span class='syllables #{valid}'>#{syllables} - </span>#{text}</div>".interpolate({
      valid: this.isValid() ? 'valid-line' : 'invalid-line',
      syllables: this.isCalculating() ? '?' : this.syllables(),
      text: this.words.invoke('toHTML').join(' ')
    });
  }
};

var Haiku = Class.create();
Haiku.prototype = {
  initialize: function(text) {
    if (text.blank()) {
      this.lines = [];
      return;
    }
    
    this.lines = text.split("\n").map(function(text, line_number){
      return new Line(text, line_number);
    });
    
    if (this.lines.length > 3)
      this.lines.length = 3;
  },
  
  isValid: function() {
    return this.lines.all(function(line){
      return line.isValid();
    });
  },

  toHTML: function() {
    return "<div>#{lines}</div>".interpolate({
      lines: this.lines.invoke('toHTML').join(' ')
    });
  }
};

Haiku.PeriodicalUpdater = Class.create();
Haiku.PeriodicalUpdater.prototype = {
  initialize: function(textArea, previewElement, submitButton) {
    this.textArea = $(textArea);
    this.previewElement = $(previewElement);
    this.submitButton = $(submitButton);
    this.lastHaikuText = '';
    this.start();
  },
  
  start: function() {
    this.timer = setInterval(this.updateHaiku.bind(this), 400);
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
        
    var request = new Ajax.Request("/syllables/" + encodedWords + ".json", {
      method: 'get',
      onComplete: function(request) {
        request.responseText.evalJSON().each(markResponded);
      }
    });
  },
     
  updateHaiku: function() {
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
    
      this.previewElement.select('.' + Word.RESPONDED).each(function(element){
          var effect = new Effect.Highlight(element);
      });    
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
};