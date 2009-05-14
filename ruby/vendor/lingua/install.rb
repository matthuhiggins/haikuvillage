require 'ftools'

PRONUNCIATION_DICTIONARY = 'redist/cmulex_pronunciation_dictionary.0.7a'
puts "preparing dictionary files; this may take some time"
require './lib/syllable/dictionary'
include Lingua::EN::Syllable
Dictionary.make_dictionary(PRONUNCIATION_DICTIONARY, 'dict')
