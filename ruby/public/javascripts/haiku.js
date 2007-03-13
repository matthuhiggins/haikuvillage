Object.extend(String.prototype, {
  compact: function() {
    return this.escapeHTML().replace(/\n +/, '\n').replace(/ +/g, ' ').strip();  
  },
  
  hash: function() {
    return '@' + this.replace(/^[^\w]|[^\w]$/, '');
  },
  
  format: function(object) {
    return new Template(this).evaluate(object);
  }
});

var Word = Class.create();
Object.extend(Word, {
  COMPLETE: 'complete',
  NEW: 'new',
  REQUESTING: 'requesting',
  RESPONDED: 'responded'
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
    return "<span class=#{state}>#{text}<sup>#{syllables}</sup></span>"
        .format({state: this.state,
                text: this.text,
                syllables: this.syllables > -1 ? this.syllables : '?'});
  }
}

var Line = Class.create();
Line.prototype = {
  initialize: function(text, line_number, wordInfo) {
    this.words = textToWords(text, wordInfo);
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
    return (this.syllables() == 5 && (this.line_number == 0 || this.line_number == 2)) 
        || (this.syllables() == 7 && this.line_number == 1);
  },
    
  toHTML: function(){
    return "<div><span class=\"syllables #{valid}\">#{syllables} - </span>#{text}</div>".format(
        {valid: this.isValid() ? 'valid-line' : 'invalid-line',
         syllables: this.isCalculating() ? '?' : this.syllables(),
         text: this.words.map(function(word){return word.toHTML();}).join(' ')});
  }
}

var Haiku = Class.create();
Haiku.prototype = {
  initialize: function(text, wordInfo) {
    if (text == "") {
      all_lines = $A([
        "type your haiku here",
        "begin the sharing process",
        "and the lord will rise"]);
    } else {
      all_lines = $A(text.split("\n"));
    }
  
    this.lines = all_lines.map(function(text, line_number){
      return new Line(text, line_number, wordInfo);
    }).findAll(function(text, line_number){
      return line_number < 3;
    });
  },
  
  isValid: function(){
    return this.lines.length == 3 &&
    this.lines.all(function(line){
      return line.isValid();
    });
  },

  toHTML: function(){
    return "<div>#{lines}</div>".format(
        {lines: this.lines.map(function(line){return line.toHTML();}).join(' ')});
  }
}

Haiku.PeriodicalUpdater = Class.create();
Haiku.PeriodicalUpdater.prototype = {
  initialize: function(textArea, previewElement) {
    this.textArea = textArea;
    this.previewElement = previewElement;
    this.lastHaikuText = "";
    this.wordInfo = $H();
    this.start();
  },
  
  start: function() {
    this.timer = setInterval(this.updateHaiku.bind(this), 400);
  },
  
  updateWordCacheHash: function (originalRequest){
    $A(originalRequest.responseText.evalJSON()).each((function(word){           
        this.wordInfo[word.text.hash()] = new Word(word.text, word.syllables, Word.RESPONDED);
    }).bind(this));
  },
   
  updateHaiku: function() {
    var wordInfo = this.wordInfo;
    var oldWordHash = $H();
    textToWords(this.lastHaikuText, wordInfo).each(function(word){
        oldWordHash[word.text.hash()] = word;
    });

    var newWordArray = textToWords($F(this.textArea), this.wordInfo);

    var wordSet = "";
    newWordArray.findAll(function(word){
        return wordInfo[word.text.hash()] != undefined && 
            wordInfo[word.text.hash()].state == Word.NEW;
    }).each(function(word){
        wordSet += (wordSet != "" ? "-" : "") + word.encoded();
        word.state = Word.REQUESTING;
    });
    
    if (wordSet != "") {
      new Ajax.Request("/syllables/" + wordSet + ".json", {
          method: "get",
          onComplete: this.updateWordCacheHash.bind(this)});
    }

    // Find the changed words from last cycle
    newWordArray.each(function(word){
      if (oldWordHash[word.text.hash()] != undefined && wordInfo[word.text.hash()] == undefined ){
        wordInfo[word.text.hash()] = word;
      }
    });
    
    // render the haiku
    newHaiku = new Haiku($F(this.textArea), wordInfo);
    $(this.previewElement).innerHTML = newHaiku.toHTML();  
    document.getElementsByClassName(Word.RESPONDED, $(this.previewElement)).each(function(element) {
      new Effect.Highlight(element, {startcolor: '#77db08'});
    });
    
    wordInfo.values().each(function(word){
        if (word.state == Word.RESPONDED){
          word.state = Word.COMPLETE;
        }
    });

    this.lastHaikuText = $F(this.textArea);
  }
}

function textToWords(text, wordInfo) {
  text = text.compact();
  return $A(text.split(/ |\n/)).map(function(value) {
    word = wordInfo[value.hash()];
    if (word == undefined)
      return new Word(value, -1, Word.NEW);
    else
      return new Word(value, word.syllables, word.state);
  });
}