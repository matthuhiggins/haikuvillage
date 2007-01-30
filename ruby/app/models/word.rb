require "lingua/syllable"
require "linguistics/linguistics.rb"
Linguistics::use(:en) # extends Array, String, and Numeric

class Word < ActiveRecord::Base
  attr_reader :text, :syllables
  
  def initialize(wordtext)
    @text = wordtext
    @syllables = count_syllables(wordtext)
  end
  
  private
  
  def count_syllables(wordtext)
    wordtext = wordtext.gsub(/^[^\w]|[^\w]$/, '')
    
    # ie boy/girl
    if wordtext =~ /\/|-/ then
      wordtext.split(/\/|-/).sum{ |word| count_syllables(word) }

    # one letter. Optionally followed by a period and more letters ie G.W.B.
    elsif wordtext =~ /^[a-zA-Z](\.[a-zA-Z]\.?)*$/ then
      wordtext.split(/\.| |/).sum{ |letter| count_letter_syllables(letter) }

    # ie 546
    elsif (wordtext =~ /^[0-9]+$/) then
      wordtext.en.numwords.split.sum{ |numeric_word| count_syllables(numeric_word) }

    # ie r2d2, v12
    elsif wordtext =~ /[a-zA-Z][0-9]|[0-9][a-zA-Z]/
      wordtext.scan(/[0-9]+|[a-zA-Z]+/).sum{ |segment| count_syllables(segment) }

    # a normal word
    else
      Lingua::EN::Syllable.syllables(wordtext)
    end
  end
  
    
  private
  
  def count_letter_syllables(letter)
    if (letter.downcase == "w")
      3
    else
      1
    end
  end
end
