module Lingua
  module EN
    module Syllable
      module Dictionary
        require 'sdbm'

        @@dictionary = nil
    
        class << self
          def syllables(word)
            word = word.upcase
            pronounce = dictionary[word]
            if pronounce.nil?
              nil
            else
              pronounce.split(/-/).grep(/^[AEIUO]/).length
            end
          end
    
          # convert a text file dictionary into dbm files. Returns the file names
          # of the created dbms.
          def make_dictionary(source_file, output_dir)
            FileUtils.mkdir(output_dir) unless File.exist?(output_dir)

            dbm = SDBM.new(File.join(output_dir, 'dict'))
      
            IO.foreach(source_file) do | line |
              next if line !~ /^[A-Z]/
              line.chomp!
              (word, *phonemes) = line.split(/  ?/)
              next if word =~ /\(\d\) ?$/ # ignore alternative pronunciations
              dbm.store(word, phonemes.join("-"))
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
