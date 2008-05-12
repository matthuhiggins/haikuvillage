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
  info        : {}
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
    this.words = textToWords(text);
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
    return this.lines.length == 3 &&
    this.lines.all(function(line){
      return line.isValid();
    });
  },

  toHTML: function() {
    return "<div>#{lines}</div>".interpolate({
      lines: this.lines.invoke('toHTML').join(' ')
    });
  }
};

function textToWords(text) {
  text = text.squish();
  return $A(text.split(/ |\n/)).map(function(value) {
    var word = Word.info[value.hash()];
    return word === undefined ? new Word(value, -1, Word.NEW) : new Word(value, word.syllables, word.state);
  });
}

Haiku.PeriodicalUpdater = Class.create();
Haiku.PeriodicalUpdater.prototype = {
  initialize: function(textArea, previewElement, submitButton) {
    this.textArea = textArea;
    this.previewElement = previewElement;
    this.submitButton = submitButton;
    this.lastHaikuText = "";
    this.start();
  },
  
  start: function() {
    this.timer = setInterval(this.updateHaiku.bind(this), 400);
  },
  
  updateWordCacheHash: function (originalRequest){
    $A(originalRequest.responseText.evalJSON()).each((function(word){           
        Word.info[word.text.hash()] = new Word(word.text, word.syllables, Word.RESPONDED);
    }).bind(this));
  },
   
  updateHaiku: function() {
    var oldWordHash = $H();
    var somethingChanged = false;
    
    if ( this.lastHaikuText != $F(this.textArea) ){
      somethingChanged = true;
    }
    
    textToWords(this.lastHaikuText).each(function(word){
      oldWordHash[word.text.hash()] = word;
    });

    var newWordArray = textToWords($F(this.textArea));

    var wordSet = "";
    newWordArray.findAll(function(word){
      return Word.info[word.text.hash()] !== undefined && Word.info[word.text.hash()].state == Word.NEW;
    }).each(function(word){
      wordSet += (wordSet !== "" ? "-" : "") + word.encoded();
      Word.info[word.text.hash()].state = Word.REQUESTING;
    });
    
    if (wordSet !== "") {
      var request = new Ajax.Request("/syllables/" + wordSet + ".json", {
        method: "get",
        onComplete: this.updateWordCacheHash.bind(this)
      });
    }

    // Find the changed words from last cycle
    newWordArray.each(function(word){
      if (oldWordHash[word.text.hash()] !== undefined && Word.info[word.text.hash()] === undefined) {
        Word.info[word.text.hash()] = word;
      }
    });
    
    // render the haiku
    var newHaiku = new Haiku($F(this.textArea));
    
    for ( var key in Word.info ){
      if ( Word.info[key].state === Word.RESPONDED ){
        somethingChanged = true;
        break;
      }
    }

    if ( somethingChanged ){
      $(this.previewElement).innerHTML = newHaiku.toHTML();
    
      $(this.previewElement).select("." + Word.RESPONDED).each(function(element){
          var effect = new Effect.Highlight(element);
      });
    }
    
    for (var key in Word.info) if (Word.info.hasOwnProperty(key)) {
      var word = Word.info[key];
      if (word.state === Word.RESPONDED) {
        word.state = Word.COMPLETE;
      }
    }
    
    $(this.submitButton).disabled = !newHaiku.isValid();

    this.lastHaikuText = $F(this.textArea);
  }
};