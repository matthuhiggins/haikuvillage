= Lingua::EN::Readability

== version 0.5
=== author Alex Fenton (alex@pressure.to)

Lingua::EN::Readability calculates statistics on English Text. It can supply counts of
words, sentences and syllables. It can also calculate several readability
measures, such as the Fog Index and Flesh-Kincaid levels.

= Features

* Syllable function either by guessing or by dictionary look-up
* Fog, Flesch and Flesch-Kincaid readability measures.

= Requirements

* (optional) gdbm or dbm
* (optional) copy of Carnegie Mellon Pronouncing Dictionary

= Installation

Basic install
	$ ruby install.rb

Install with bundled dictionary, default to bundled dictionary if file not 
specified
	$ ruby install.rb --with-dictionary=[dictfile]
	
= Synopsis
	
	require 'lingua/en/readability'
	
	text = 'This is the text sample to be analysed.'
	report = Lingua::EN::Readability.new(text)
	report.num_sentences # 1
	report.num_words     # 8
	report.num_syllables # 12
	report.report        # a formatted summary of statistics and measures

= Readability

Readability statistics are an attempt to measure how easy a sample of text is to
read, based on formal characteristics. Features of the text sample, such as the
average word length of sentences and the relative frequency of complex or
unfamiliar words are taken to indicate more challenging texts which demand a
greater level of skill in the reader to comprehend the text. These statistics 
should be treated with some caution, as they do not reflect the effect of 
physical factors like text size, colour and typeface on readability. They also
cannot reflect the effect of the reader's motivation, or any unusual  
knowledge needed to understand words used in specialist or technical contexts.
However, they can supply a useful quick measure of the complexity of a range of 
ordinary texts.

This module implements three measures (Fog, Flesch and Kincaid) which are
relatively easy to derive automatically. For a fuller discussion of how these
are calculated and interpreted, plus a wider discussion of readability, see:

http://www.as.wvu.edu/~tmiles/fog.html

= Object-oriented usage

Although the default usage is based around static module methods, it is easy to 
add the methods into instances of String class:
 
	class String
		include Lingua::EN
		def readability
			Readability.new(self)
		end
	end

	report = "This is a sample text to be analysed".readability

If the module is used in this style at the moment, the figures in the report
will *not* be updated if the text string is changed.

= Using a Pronunciation Dictionary

By default, the Lingua::EN::Syllable module guesses the number of syllables in
a written English word by guessing based on the word's shape. However, it can't
always guess correctly, as English spelling is quite complicated and not totally
predictable. On fairly standard English texts, it gets it right roughly 95%
of the time, and this is probably good enough. For more accuracy, it is possible
to use a Pronouncing Dictionary, such as that available free from Carnegie
Mellon at http://www.speech.cs.cmu.edu/cgi-bin/cmudict

To take advantage of this, run or re-run the installation script with the -d or 
--with-dictionary option, pointing to the dictionary file.
 	$ ruby install.rb --with-dictionary=/file/path/to/dictionary
 	
The installer will take some time to convert the plain text file into a dbm hash
which is used as a dictionary for look-ups. The default Lingua::EN::Syllable
module will use the most accurate technique automatically, using a dictionary if
available or guessing if not. However, it is possible to manually access each
of the techniques.

	require 'lingua/en/syllable/dictionary'
	syll = Lingua::EN::Syllable::Dictionary.syllables('nevertheless')
	puts syll # 4
	
	require 'lingua/en/syllable/guess'
	syll = Lingua::EN::Syllable::Dictionary.syllables('nevertheless')
	puts syll # 3 ... ah, well, we can't guess right *all* the time

= Limitations

* Some measuremeants incorrectly include proper names in counting syllables.

= TODO

* Optimisations to Syllable::Guess;
* Unit tests;
* Other readability statistics, e.g. Dale-Chall, Fry. I would appreciate any
  information about the underlying numbers used to generate the Fry Readability
  Graph (see http://school.discovery.com/schrockguide/fry/fry.html);
* Any bugs: please mail to alex@pressure.to;