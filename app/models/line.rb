class Line < ActiveRecord::Base
  attr_reader :words
  
  def initialize(linetext)
    @words = []
    logger.debug(linetext.inspect)
    for word in linetext.split
      @words << Word.new(word)
    end
  end
  
  def syllables
    @words.sum { |word| word.syllables }
  end
  
  def text
    @words.map { |word| word.text }.join(" ")
  end
  
end