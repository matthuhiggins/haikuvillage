Object.extend(String.prototype, {
  compact: function() {
    return this.replace(/\n +/, '\n').replace(/ +/g, ' ').replace(/^\s+|\s+$/, '');  
  },
  
  hash: function() {
    return '@' + this.replace(/^[^\w]|[^\w]$/, '');
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

Object.extend(Word.prototype, {
  initialize: function(text, syllables, state) {
    this.text = text;
    this.syllables = syllables;
    this.state = state;
  },

  toElement: function(){
    wordSpan = document.createElement('span');
    wordSpan.innerHTML = this.text;
    if (this.state == Word.RESPONDED && this.syllables > 0)
      Element.addClassName(wordSpan, Word.NEW);
    syllableSup = document.createElement('sup');
    syllableSup.innerHTML = this.syllables > -1 ? this.syllables : '?';
    wordSpan.appendChild(syllableSup);
    return wordSpan;
  }
});

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

function isValidSyllables(syllables, row){
  return (syllables == 5 && (row == 0 || row == 2)) || (syllables == 7 && row == 1);
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
    
  toElement: function(){
    lineDiv = document.createElement('div');
    syllableSpan = document.createElement('span');
    syllableSpan.addClassName(isValidSyllables(this.syllables(), this.line_number) ?
        'valid-line' : 'invalid-line');
    syllableSpan.addClassName('syllables');
    syllableSpan.innerHTML = (this.isCalculating() ? '?' : this.syllables()) + ' - ';
    lineDiv.appendChild(syllableSpan);
    this.words.each(function(word){
      lineDiv.appendChild(word.toElement());
      lineDiv.innerHTML += " ";
    });
    return lineDiv;
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

  toElement: function(){
    haikuDiv = document.createElement('div');
    this.lines.each(function(line, index){
      haikuDiv.appendChild(line.toElement());
    });
    return haikuDiv;
  }
}

function isValidHaiku(haiku){
  return haiku.lines.length == 3 &&
    isValidSyllables(haiku.lines[0].syllables(), 0) &&
    isValidSyllables(haiku.lines[1].syllables(), 1) &&
    isValidSyllables(haiku.lines[2].syllables(), 2);
}

function encodeHaikuWord(word){
  return encodeURIComponent(word.replace(/\./g, '%2e').replace(/\-/g, '%2d'));
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
      wordSet += (wordSet != "" ? "-" : "") + encodeHaikuWord(word.text);
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
       
  return isValidHaiku(newHaiku);
}

function renderHaiku(haiku, element){
  element.innerHTML = "";
  element.appendChild(haiku.toElement());
  
  document.getElementsByClassName("new", element).each(function(element) {
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