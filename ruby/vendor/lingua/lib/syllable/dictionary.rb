module Lingua
  module EN
    module Syllable
      module Dictionary
        require 'sdbm'

        class LookUpError < IndexError
        end
    
        @@dictionary = nil
    
        class << self
          # Look up word in the dbm dictionary.
          def syllables(word)
            word = word.upcase
            begin
              pronounce = dictionary.fetch(word)
            rescue IndexError
              if word =~ /'/
                word = word.delete "'"
                retry
              end
              raise LookUpError, "word #{word} not in dictionary"
            end

            pronounce.split(/-/).grep(/^[AEIUO]/).length
          end

          def dictionary
            if @@dictionary.nil?
              load_dictionary
            end
            @@dictionary
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
            def load_dictionary
              @@dictionary = SDBM.new(__FILE__[0..-14] + 'dict')
              if @@dictionary.keys.length.zero?
                raise LoadError, "dictionary file not found"
              end
            end
        end
      end
    end
  end
end
