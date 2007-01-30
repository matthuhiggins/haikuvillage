// Both strips and converts multiple spaces to one.
String.prototype.compact = function() {
  return this.replace(/\n +/, '\n').replace(/ +/g, ' ').replace(/^\s+|\s+$/, '');
};

String.prototype.hash = function() {
  return '@' + this.replace(/^[^\w]|[^\w]$/, '');
};


var wordCacheHash = $H();

function Word() {
  this.text = arguments[0];
  this.syllables = arguments[1];
  this.state = arguments[2];

  this.toElement = function(){
    wordSpan = document.createElement('span');
    wordSpan.innerHTML = this.text;
    if (this.state == "responded" && this.syllables > 0)
      Element.addClassName(wordSpan, 'new');
    syllableSup = document.createElement('sup');
    syllableSup.innerHTML = this.syllables > -1 ? this.syllables : '?';
    wordSpan.appendChild(syllableSup);
    return wordSpan;
  }
}

function isValidSyllables(syllables, row){
  return (syllables == 5 && (row == 0 || row == 2)) || (syllables == 7 && row == 1);
}

function Line() {
  this.words = $A();
  this.row = -1;

  this.isCalculating = function(){
    return this.words.any(function(word){
      return word.syllables < 0;
    });
  }

  this.syllables = function(){
    return eval(this.words.map(function(word){
      return word.syllables;
    }).join("+"));
  }
    
  this.toElement = function(){
    lineDiv = document.createElement('div');
    syllableSpan = document.createElement('span');
    syllableSpan.addClassName(isValidSyllables(this.syllables(), this.row) ?
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

function Haiku(){
  this.lines = null;

  this.toElement = function(){
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

function textToWords(text) {
  text = text.compact();
  return $A(text.split(/ |\n/)).map(function(value) {
    word = wordCacheHash[value.hash()];
    if (word == undefined)
      return new Word(value, -1, "new");
    else
      return new Word(value, word.syllables, word.state);
  });
}
function textToLine(text, index){
  l = new Line();
  l.words = textToWords(text);
  l.row = index;
  return l;
}

function textToHaiku(text){
  h = new Haiku();
  h.lines = $A(text.split("\n")).map(function(line, index){
    return textToLine(line, index);
  }).findAll(function(line, index){
    return index < 3;
  });
  return h;
}

function encodeHaikuWord(word){
  return encodeURIComponent(word.replace(/\./g, '%2e').replace(/\-/g, '%2d'));
}

function haikuMaster(oldValue, newValue, element) {
    //populate hash of haiku from previous tick
  oldWordHash = $H();  
  textToWords(oldValue).each(function(word){
    oldWordHash[word.text.hash()] = word;
  });
  
  //populate hash of current haiku
  var newWordArray = textToWords(newValue);
  newWordHash = $H();  
  newWordArray.each(function(word){
    newWordHash[word.text.hash()] = word;
  });
  
  //get rid of words that were in the cache for one cycle
  wordCacheHash.each(function(kvPair){
     if (kvPair.value.state == "new" && 
         newWordHash[kvPair.value.text.hash()] == undefined) {
         delete wordCacheHash[kvPair.value.text.hash()];
        }
  });  
  
  //ajax any new words left in the cache
    wordSet = "";
    newWordHash.findAll(function(kvPair){
     return wordCacheHash[kvPair.value.text.hash()] != undefined && 
             wordCacheHash[kvPair.value.text.hash()].state == "new";
  }).each(function(kvPair){
      wordSet += (wordSet != "" ? "-" : "") + encodeHaikuWord(kvPair.value.text);
        kvPair.value.state = "requesting";
  });
    if (wordSet != "")
        new Ajax.Request("/syllables/" + wordSet + ".json", {
            method: "get",
            onComplete: updateWordCacheHash
        });  

  //Find the changed words from last cycle
  newWordArray.each(function(word){
    if (oldWordHash[word.text.hash()] != undefined && 
        wordCacheHash[word.text.hash()] == undefined ){
      wordCacheHash[word.text.hash()] = word;
    }
  });
    
  newHaiku = textToHaiku(newValue);  
  oldHaiku = textToHaiku(oldValue);
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
     if ( kvPair.value.state == "responded"){
      kvPair.value.state = "static";
     }
  });
}

function updateWordCacheHash( originalRequest ){
  var response = eval("(" + originalRequest.responseText + ")");
  $A(response).each(function(item){
        wordCacheHash[item.text.hash()] = new Word(item.text, item.syllables, "responded");
    });
}