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
    wordtext = wordtext.gsub(/^[^\w]+|[^\w]+$|"+/, '')
         
    # ie spiz's or mike's
    if wordtext =~ /'s$/ then
      wordtext = wordtext.gsub( /'s$/, '')
      (if wordtext =~ /^6$|[0|2-9]6$|[x|z]$/ then 1 else 0 end) + count_syllables(wordtext)

    # ie boy/girl or re-factor
    elsif wordtext =~ /\/|-/ then
      wordtext.split(/\/|-/).sum{ |word| count_syllables(word) }

    # one letter. Optionally followed by a period and more letters ie G.W.B.
    elsif wordtext =~ /^[a-zA-Z](\.[a-zA-Z]\.?)*$/ then
      wordtext.split(/\.| |/).sum{ |letter| count_letter_syllables(letter) }

    # ie 546
    elsif wordtext =~ /^[0-9]+$/ then
      wordtext.en.numwords.split.sum{ |numeric_word| count_syllables(numeric_word) }
      
    # ie 3:15
    elsif wordtext =~ /^[0-9][1|2]?:[0-5][0-9]$/ then
      wordtext.split(/:/).sum{ |number| count_syllables(number) }

    # ie 1st or 2nd or 101st
    elsif wordtext =~ /^[0-9]+(st|rd|th)$/ then
      wordtext = wordtext.gsub(/(st|rd|th)$/, '')
      if [10,12].include?(wordtext.to_i % 100) || wordtext.to_i % 10 == 0
        count_syllables(wordtext)
      elsif [0,2].include?(wordtext.to_i % 10)
        count_syllables(wordtext) + 1
      else
        count_syllables(wordtext)        
      end

    # ie r2d2, v12
    elsif wordtext =~ /[a-zA-Z][0-9]|[0-9][a-zA-Z]/
      wordtext.scan(/[0-9]+|[a-zA-Z]+/).sum{ |segment| count_syllables(segment) }

    # a normal word
    elsif wordtext =~ /^[a-zA-Z|']+$/ then
      Lingua::EN::Syllable.syllables(wordtext)
      
    # the word is not countable.
    else
      0
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
