module Lingua
  module EN
    module Syllable
      require 'syllable/dictionary'
      require 'syllable/guess'
		
  		def self.syllables(word)
  			Dictionary::syllables(word) || Guess::syllables(word)
  		end
    end
  end
end