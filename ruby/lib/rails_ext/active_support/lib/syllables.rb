class String
  LONGEST_SYLLABLE = 'strengths'.length.to_f
  def syllables
    cleaned_word = self.gsub(/^[^\w]+|[^\w]+$|"+/, '').chomp
    [cleaned_word.guess_syllables, (self.length / LONGEST_SYLLABLE).ceil].max
  end
  
  protected
    def guess_syllables
      # ie spiz's or mike's
      if self =~ /'s$/
        value = self.gsub( /'s$/, '')
        (value =~ /^6$|[0|2-9]6$|[x|z]$/ ? 1 : 0) + value.syllables

      # ie boy/girl or re-factor
      elsif self =~ /\/|-/
        self.split(/\/|-/).sum(&:syllables)
      
      # version or decimal such as v1.0 or 10.5
      elsif self =~ /\d+\.\d+/
        self.split(".").sum(&:syllables) + 1

      # single letter
      elsif self =~ /^[a-zA-Z]$/
        self.downcase == "w" ? 3 : 1
      
      # ie 1st or 2nd or 101st
      elsif self =~ /^[0-9]+(st|rd|th|nd)$/
        value = self.gsub(/(st|rd|th|nd)$/, '')
        if [0, 2].include?(value.to_i % 10) && ![0, 10, 12].include?(value.to_i % 100)
          value.syllables + 1
        else
          value.syllables
        end

      # one letter, optionally followed by a period and more letters ie G.W.B.
      elsif self =~ /^[a-zA-Z](\.[a-zA-Z]\.?)*$/
        self.split(/\.| |/).sum(&:syllables)
  
      # ie USA. assumed to be an acronym
      elsif self =~ /^[A-Z]+$/
        self.split(//).sum(&:syllables)
      
      # ie r2d2, v12
      elsif self.downcase =~ /^([a-z]+[0-9]+|[0-9]+[a-z]+)+$/
        self.scan(/[0-9]+|[a-zA-Z]+/).sum(&:syllables)

      # ie 546
      elsif self =~ /^[0-9]+$/ then
        self.dup.en.numwords.split.sum(&:syllables)

      # ie 3:15
      elsif self =~ /^[0-9][1|2]?:[0-5][0-9]$/
        self.split(/:/).sum(&:syllables)

      # a normal word
      elsif self =~ /^[a-zA-Z|']+$/ then
        Lingua::EN::Syllable::syllables(self)
    
      # the word is not countable.
      else
        0
      end
    end
end
