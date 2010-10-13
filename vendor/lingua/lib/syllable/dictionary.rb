module Lingua
  module EN
    module Syllable
      module Dictionary
        require 'sdbm'

        @@dictionary = nil
    
        class << self
          def syllables(word)
            word = word.upcase
            syllables = dictionary[word].try(:to_i)
            syllables
          end
    
          def make_dictionary(source_file, output_dir)
            FileUtils.mkdir(output_dir) unless File.exist?(output_dir)

            dbm = SDBM.new(File.join(output_dir, 'dict'))
      
            IO.foreach(source_file) do |line|
              next if line !~ /^[A-Z]/
              line.chomp!
              (word, *phonemes) = line.split(/  ?/)
              next if word =~ /\(\d\) ?$/ # ignore alternative pronunciations

              syllables = phonemes.grep(/^[AEIUO]/).size

              if syllables != Syllable::Guess.syllables(word)
                dbm.store(word, syllables.to_s)
              end
            end

            dbm.close
          end
    
          private
            def dictionary
              @@dictionary ||= load_dictionary
            end

            def load_dictionary
              dictionary = SDBM.new(File.dirname(__FILE__) + '/dict')
              (raise LoadError, "dictionary file not found") if dictionary.keys.length.zero?
              dictionary
            end
        end
      end
    end
  end
end
