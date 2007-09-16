class Line < ActiveRecord::Base
  attr_reader :words
  
  def initialize(linetext)
    @words = linetext.split.map{ |word| Word.new(word) }
  end
  
  def syllables
    @words.sum{ |word| word.syllables }
  end
end