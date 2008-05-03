require 'getoptlong'
require 'rbconfig'
require 'ftools'

include Config


options = GetoptLong.new
options.set_options(
	[ "-d", "--with-dictionary", GetoptLong::OPTIONAL_ARGUMENT ],
	[ "-h", "--help", GetoptLong::NO_ARGUMENT ]
)

options.each do | opt, arg |
	if opt == '-d'
		if arg.empty?
			$dictfile = 'redist/cmulex_pronunciation_dictionary.0.6'
		else	
			$dictfile = arg
		end
	elsif opt == '-h'
		DATA.each { | line | print line }
		exit
	end
end

def install_libraries(files)
  files.each do |aFile, dest|
    aFile = File.expand_path(aFile)
    File::makedirs(dest)
    File::install(aFile, File.join(dest, File.basename(aFile)), 0644, true)
  end
end

if $0 == __FILE__
	version = CONFIG["MAJOR"]+"." + CONFIG["MINOR"]
	libdir = File.join(CONFIG["libdir"], "ruby", version)
	sitedir = CONFIG["sitedir"] || File.join(libdir, "site_ruby")
	siteverdir = File.join(sitedir, version)
	lingua_dest = File.join(siteverdir, "lingua")
	en_dest = File.join(lingua_dest, "en")
	syll_dest = File.join(en_dest, "syllable")
	
	# files to install
	lib_files = { "./lib/readability.rb"     => en_dest,
	  			  "./lib/sentence.rb"        => en_dest,
	 			  "./lib/syllable.rb"        => en_dest,
	  			  "./lib/syllable/guess.rb"  => syll_dest }
	install_libraries(lib_files)
	
	# prepare and install dictionaries if desired
	if $dictfile
		puts "preparing dictionary files; this may take some time"
		require './lib/syllable/dictionary'
		include Lingua::EN::Syllable
    # begin
			for dict_file in Dictionary.make_dictionary($dictfile, 'dict')
				install_libraries(dict_file => syll_dest)
			end
			install_libraries("./lib/syllable/dictionary.rb" => syll_dest )
    # rescue => err
      # puts "failed making dictionary: #{err.backtrace}"
    # end
	end
end

__END__
Usage:
ruby install.rb --with-dictionary=/file/path/of/dictionary

Options:
-d [dictfile] / --with-dictionary[=dictfile]
Make and install a dictionary of pronunciations using a specified text
dictionary as a source. If no dictionary is specified, attempt to use a file
in the ./redist directory.

-h / --help
Print this help message.
