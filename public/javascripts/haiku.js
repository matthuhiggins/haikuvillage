var wordHash = $H(
{
	hello: new Word("hello", 2, false),
	idea: new Word("idea", 3, false),
	world: new Word("world", 1, false)
});

function Word() {
	this.text = arguments[0];
	this.syllables = arguments[1];
	this.isNew = arguments[2];

	this.toSpanTag = function(){
		return "<span " + (this.isNew ? "class=\"new\"" : "") +
				">" + this.text + "<sup>" + this.syllables + "</sup></span>";
	}
}

function $W(text) {
	return $A(text.split(" ")).map(function(value) {
		return wordHash[value] == undefined ? new Word(value, 1, true) :	wordHash[value];
	});
}

// AJAX AJAX AJAX!
function updateWordHash(text) {
	wordHash.each(function(word2){
		word2.value.isNew = false;
	});

	$W(text).findAll(function(word){
			return wordHash[word.text] == undefined;
		}).each(function(word){
			wordHash[word.text] = new Word(word.text, 1, true);
		});
}

function haikuMaster(oldValue, newValue, element) {
	updateWordHash(newValue);
	
	element.innerHTML = $W(newValue).map(function(word) {
			return word.toSpanTag();
		}).join(" ");

	document.getElementsByClassName("new", element).each(function(element) {
			new Effect.Highlight(element);
		});
}
