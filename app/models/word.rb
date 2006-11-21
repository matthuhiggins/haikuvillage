require "lingua/syllable"

class Word < ActiveRecord::Base
  attr_reader :text
  
  def initialize(wordtext)
    @text = wordtext
  end
  
  def syllables
    Lingua::EN::Syllable.syllables(@text)
  end
end
