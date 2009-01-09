class Line
  attr_reader :words

  def initialize(text)
    @words = text.split
  end

  def syllables
    words.sum(&:syllables)
  end
end