require "lingua/syllable"

class Word < ActiveRecord::Base
  attr_reader :text, :syllables
  
  def initialize(wordtext)
    @text = wordtext
    @syllables = count_syllables(wordtext)
  end
  
  private
  
  def count_syllables(wordtext)
    Lingua::EN::Syllable.syllables(wordtext)
  end
end
