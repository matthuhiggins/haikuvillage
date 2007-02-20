Object.extend(String.prototype, {
  compact: function() {
    return this.escapeHTML().replace(/\n +/, '\n').replace(/ +/g, ' ').strip();  
  },
  
  hash: function() {
    return '@' + this.replace(/^[^\w]|[^\w]$/, '');
  },
  
  mixin: function(object) {
    return new Template(this).evaluate(object);
  }
});

var wordCacheHash = $H();

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
        .mixin({state: this.state,
                text: this.text,
                syllables: this.syllables > -1 ? this.syllables : '?'});
  }
}

function textToWords(text) {
  text = text.compact();
  return $A(text.split(/ |\n/)).map(function(value) {
    word = wordCacheHash[value.hash()];
    if (word == undefined)
      return new Word(value, -1, Word.NEW);
    else
      return new Word(value, word.syllables, word.state);
  });
}

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
    return (this.syllables() == 5 && (this.line_number == 0 || this.line_number == 2)) 
        || (this.syllables() == 7 && this.line_number == 1);
  },
    
  toHTML: function(){
    return "<div><span class=\"syllables #{valid}\">#{syllables} - </span>#{text}</div>".mixin(
        {valid: this.isValid() ? 'valid-line' : 'invalid-line',
         syllables: this.isCalculating() ? '?' : this.syllables(),
         text: this.words.map(function(word){return word.toHTML();}).join(' ')});
  }
}

var Haiku = Class.create();
Haiku.prototype = {
  initialize: function(text) {
    if (text == "") {
      all_lines = $A([
        "type your haiku here",
        "begin the sharing process",
        "and the lord will rise"]);
    } else {
      all_lines = $A(text.split("\n"));
    }
  
    this.lines = all_lines.map(function(text, line_number){
      return new Line(text, line_number);
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
    return "<div>#{lines}</div>".mixin(
        {lines: this.lines.map(function(line){return line.toHTML();}).join(' ')});
  }
}

function haikuMaster(oldValue, newValue, element) {
  // populate hash of haiku from previous tick
  oldWordHash = $H();  
  textToWords(oldValue).each(function(word){
    oldWordHash[word.text.hash()] = word;
  });
  
  // populate hash of current haiku
  var newWordArray = textToWords(newValue);
  
  // ajax any new words left in the cache
  wordSet = "";
  newWordArray.findAll(function(word){
      return wordCacheHash[word.text.hash()] != undefined && 
          wordCacheHash[word.text.hash()].state == Word.NEW;
  }).each(function(word){
      wordSet += (wordSet != "" ? "-" : "") + word.encoded();
      word.state = Word.REQUESTING;
  });
  
  if (wordSet != "") {
    new Ajax.Request("/syllables/" + wordSet + ".json", {
            method: "get",
            onComplete: updateWordCacheHash});
  }

  // Find the changed words from last cycle
  newWordArray.each(function(word){
    if (oldWordHash[word.text.hash()] != undefined && wordCacheHash[word.text.hash()] == undefined ){
      wordCacheHash[word.text.hash()] = word;
    }
  });
    
  newHaiku = new Haiku(newValue);  
  renderHaiku(newHaiku, element);
       
  return newHaiku.isValid();
}

function renderHaiku(haiku, element){
  element.innerHTML = haiku.toHTML();
  
  document.getElementsByClassName(Word.RESPONDED, element).each(function(element) {
      new Effect.Highlight(element, {startcolor: '#77db08'});
    });
  
  wordCacheHash.each(function(kvPair){
     if (kvPair.value.state == Word.RESPONDED){
      kvPair.value.state = Word.COMPLETE;
     }
  });
}

function updateWordCacheHash(originalRequest){
  var response = eval("(" + originalRequest.responseText + ")");
  $A(response).each(function(word){
        wordCacheHash[word.text.hash()] = new Word(word.text, word.syllables, Word.RESPONDED);
    });
}