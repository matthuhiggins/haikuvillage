class Word
  class << self
    def count_syllables(word_text)
      [guess_syllables(word_text), (word_text.length / LONGEST_SYLLABLE).ceil].max
    end
  
    def guess_syllables(word_text)         
      # ie spiz's or mike's
      if word_text =~ /'s$/
        word_text = word_text.gsub( /'s$/, '')
        (word_text =~ /^6$|[0|2-9]6$|[x|z]$/ ? 1 : 0) + count_syllables(word_text)

      # ie boy/girl or re-factor
      elsif word_text =~ /\/|-/
        word_text.split(/\/|-/).sum { |word| count_syllables(word) }

      # one letter, optionally followed by a period and more letters ie G.W.B.
      elsif word_text =~ /^[a-zA-Z](\.[a-zA-Z]\.?)*$/
        word_text.split(/\.| |/).sum { |letter| count_letter_syllables(letter) }
    
      # ie USA. assumed to be an acronym
      elsif word_text =~ /^[A-Z]+$/
        word_text.split(//).sum { |letter| count_letter_syllables(letter) }

      # ie 546
      elsif word_text =~ /^[0-9]+$/ then
        word_text.en.numwords.split.sum { |numeric_word| count_syllables(numeric_word) }

      # ie 3:15
      elsif word_text =~ /^[0-9][1|2]?:[0-5][0-9]$/
        word_text.split(/:/).sum { |number| count_syllables(number) }

      # ie 1st or 2nd or 101st
      elsif word_text =~ /^[0-9]+(st|rd|th|nd)$/
        word_text = word_text.gsub(/(st|rd|th|nd)$/, '')
        if ([0, 2].include?(word_text.to_i % 10)) && (word_text.to_i % 100 != 10)
          count_syllables(word_text) + 1
        else
          count_syllables(word_text)
        end

      # ie r2d2, v12
      elsif word_text =~ /[a-zA-Z][0-9]|[0-9][a-zA-Z]/
        word_text.scan(/[0-9]+|[a-zA-Z]+/).sum { |segment| count_syllables(segment) }

      # a normal word
      elsif word_text =~ /^[a-zA-Z|']+$/ then
        Lingua::EN::Syllable::syllables(word_text)
      
      # the word is not countable.
      else
        0
      end
    end
  
    def count_letter_syllables(letter)
       letter.downcase == "w" ? 3 : 1
    end
  end
  
  attr_reader :text, :syllables
  acts_as_cached
  
  LONGEST_SYLLABLE = 'strengths'.length.to_f # From the MikeSpizDB
    
  def initialize(word_text)
    @text = word_text.gsub(/^[^\w]+|[^\w]+$|"+/, '').chomp
    @syllables = get_cache("word_count:#{word_text}") { self.class.count_syllables(word_text) }
  end
end
