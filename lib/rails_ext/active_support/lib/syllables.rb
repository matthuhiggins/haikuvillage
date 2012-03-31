class String
  LONGEST_SYLLABLE = 'strengths'.length.to_f
  def syllables
    cleaned_word = self.gsub(/^[^\w]+|[^\w]+$|"+/, '').chomp
    [cleaned_word.guess_syllables, (self.length / LONGEST_SYLLABLE).ceil].max
  end
  
  protected
    def guess_syllables
      case self
      # ie spiz's or mike's
      when /'s$/
        value = self.gsub( /'s$/, '')
        (value =~ /^6$|[0|2-9]6$|[x|z]$/ ? 1 : 0) + value.syllables

      # ie boy/girl or re-factor or accidental red,blue
      when /\/|-|,/
        self.split(/\/|-|,/).sum(&:syllables)
      
      # version or decimal such as v1.0 or 10.5
      when /\d+\.\d+/
        self.split(".").sum(&:syllables) + 1

      # single letter
      when /^[a-zA-Z]$/
        self.downcase == "w" ? 3 : 1
      
      # ie 1st or 2nd or 101st
      when /^[0-9]+(st|rd|th|nd)$/
        value = self.gsub(/(st|rd|th|nd)$/, '')
        if [0, 2].include?(value.to_i % 10) && ![0, 10, 12].include?(value.to_i % 100)
          value.syllables + 1
        else
          value.syllables
        end

      # one letter, optionally followed by a period and more letters ie G.W.B.
      when /^[a-zA-Z](\.[a-zA-Z]\.?)*$/
        self.split(/\.| |/).sum(&:syllables)
  
      # ie USA. assumed to be an acronym
      when /^[A-Z]+$/
        self.split(//).sum(&:syllables)
      
      # ie r2d2, v12
      when /^([a-z]+[0-9]+|[0-9]+[a-z]+)+$/i
        self.scan(/[0-9]+|[a-zA-Z]+/).sum(&:syllables)

      # ie 546
      when /^[0-9]+$/
        Linguistics::EN.numwords(self).split.sum(&:syllables)

      # ie 3:15
      when /^[0-9][1|2]?:[0-5][0-9]$/
        self.split(/:/).sum(&:syllables)

      # a normal word
      when /^[a-zA-Z|']+$/ then
        Lingua::EN::Syllable::syllables(self)
    
      # the word is not countable.
      else
        0
      end
    end
end
