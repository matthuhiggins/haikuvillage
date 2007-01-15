require "lingua/syllable"
require "lingusitics/linguistics"
Linguistics::use(:en) # extends Array, String, and Numeric

class Word < ActiveRecord::Base
  attr_reader :text, :syllables
  
  def initialize(wordtext)
    @text = wordtext
    @syllables = count_syllables(wordtext)
  end
  
  private
  
  def count_syllables(wordtext)
    #
    #  count_letter_syllables(wordtext)
    #else
    if (wordtext.length == 1) and (wordtext =~ /[a-zA-Z]/) then
      count_letter_syllables(wordtext)
    elsif (wordtext =~ /^[0-9]/) then
      wordtext.en.numwords.split.sum{ |numeric_word| count_syllables(numeric_word) }
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
