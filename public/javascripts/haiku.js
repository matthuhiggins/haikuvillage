// Both strips and converts multiple spaces to one.
String.prototype.compact = function() {
	return this.replace(/\n +/, '\n').replace(/ +/g, ' ').replace(/^\s+|\s+$/, '');
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
		syllableSup.innerHTML = this.syllables > 0 ? this.syllables : '?';
		wordSpan.appendChild(syllableSup);
		return wordSpan;
	}
}

function isValidSyllables(syllables, row){
	return (syllables == 5 && (row == 0 || row == 2)) ||
			(syllables == 7 && row == 1);
}

function Line() {
	this.words = $A();
	this.row = -1;

	this.isCalculating = function(){
		return this.words.any(function(word){
			return word.syllables < 1;
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
				'valid' : 'invalid');
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
		return wordCacheHash[value] == undefined ? new Word(value, 0, "new") : wordCacheHash[value];
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

//TODO: Allow for use of more than one haiku on the page
//var wordRequestHash = $H();

function haikuMaster(oldValue, newValue, element) {
	var curHaikuWords = textToWords(newValue);

	oldWordHash = $H();	
	textToWords(oldValue).each(function(word){
		oldWordHash[word.text] = word;
	});
	
	//get rid of any "new" words that are not in the current haiku
	wordCacheHash.each(function(word){
	   if ( curHaikuWords[word.text] == undefined ){
	       wordCacheHash[word.text] = undefined;
	   }
	});
	
	//request any new words
	wordCacheHash.each(function(word){
        if ( word.state == "new" ){
            word.state = "requested";
    		new Ajax.Request("/syllables/" + word.value.text + ";json", {
    			method: "get",
    			onComplete: updateWordCacheHash
    		});
    	}
	});
	
	//Find the changed words from last cycle
	curHaikuWords.each(function(word){
		if (oldWordHash[word.text] != undefined && 
		    wordCacheHash[word.text] == undefined ){
			word.state = "new";
			wordCacheHash[word.text] = word;
		} 
	});
		
	haiku = renderHaiku( newValue, element );
	return isValidHaiku(haiku);
}

function renderHaiku( haikuText, element ){
	element.innerHTML = "";
	haiku = textToHaiku(haikuText);
	element.appendChild(haiku.toElement());
	
	document.getElementsByClassName("new", element).each(function(element) {
			new Effect.Highlight(element, {startcolor: '#77db08'});
		});
		
	wordCacheHash.each(function(word2){
	   if ( word2.state == "responded"){
		  word2.value.state = "static";
	   }
	});
	
	return haiku;
}

function updateWordCacheHash( originalRequest ){
	var response = eval("(" + originalRequest.responseText + ")");
	wordCacheHash[response.word] = new Word(response.word, response.syllables, "responded");
}