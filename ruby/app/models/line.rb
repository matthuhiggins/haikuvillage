class Line
  attr_reader :words
  
  def initialize(text)
    @words = text.split.map{ |word| Word.new(word) }
  end
  
  def syllables
    words.sum &:syllables
  end
end