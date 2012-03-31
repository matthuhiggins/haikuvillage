module Linguistics::EN
	Linguistics::DefaultLanguages.push( :en )

	@lprintf_formatters = {}
	class << self
		attr_accessor :lprintf_formatters
	end
	
	### Add the specified method (which can be either a Method object or a
	### Symbol for looking up a method)
	def self::def_lprintf_formatter( name, meth )
		meth = self.method( meth ) unless meth.is_a?( Method )
		self.lprintf_formatters[ name ] = meth
	end
	
	# Numerical inflections
	Nth = {
		0 => 'th',
		1 => 'st',
		2 => 'nd',
		3 => 'rd',
		4 => 'th',
		5 => 'th',
		6 => 'th',
		7 => 'th',
		8 => 'th',
		9 => 'th',
		11 => 'th',
		12 => 'th',
		13 => 'th',
	}

	# Ordinal word parts
	Ordinals = {
		'ty' => 'tieth',
		'one' => 'first',
		'two' => 'second',
		'three' => 'third',
		'five' => 'fifth',
		'eight' => 'eighth',
		'nine' => 'ninth',
		'twelve' => 'twelfth',
	}
	OrdinalSuffixes = Ordinals.keys.join("|") + "|"
	Ordinals[""] = 'th'

	# Numeral names
	Units = [''] + %w[one two three four five six seven eight nine]
	Teens = %w[ten eleven twelve thirteen fourteen
			  fifteen sixteen seventeen eighteen nineteen]
	Tens  = ['',''] + %w[twenty thirty forty fifty sixty seventy eighty ninety]
	Thousands = [' ', ' thousand'] + %w[
		m b tr quadr quint sext sept oct non dec undec duodec tredec
		quattuordec quindec sexdec septemdec octodec novemdec vigint
	].collect {|prefix| ' ' + prefix + 'illion'}

	# A collection of functions for transforming digits into word
	# phrases. Indexed by the number of digits being transformed; e.g.,
	# <tt>NumberToWordsFunctions[2]</tt> is the function for transforming
	# double-digit numbers.
	NumberToWordsFunctions = [
		proc {|*args| raise "No digits (#{args.inspect})"},

		# Single-digits
		proc {|zero,x|
			(x.nonzero? ? to_units(x) : "#{zero} ")
		},

		# Double-digits
		proc {|zero,x,y|
			if x.nonzero?
				to_tens( x, y )
			elsif y.nonzero?
				"#{zero} " + NumberToWordsFunctions[1].call( zero, y )
			else
				([zero] * 2).join(" ")
			end
		},

		# Triple-digits
		proc {|zero,x,y,z|
			NumberToWordsFunctions[1].call(zero,x) + 
			NumberToWordsFunctions[2].call(zero,y,z)
		}
	]


	# Default configuration arguments for the #numwords function
	NumwordDefaults = {
		:group		=> 0,
		:comma		=> ', ',
		:and		=> ' and ',
		:zero		=> 'zero',
		:decimal	=> 'point',
		:asArray	=> false,
	}

	# :startdoc:

	#################################################################
	###	" B A C K E N D "   F U N C T I O N S
	#################################################################


	###############
	module_function
	###############

	### Debugging output
	def debug_msg( *msgs ) # :nodoc:
		$stderr.puts msgs.join(" ") if $DEBUG
	end


	### Normalize a count to either 1 or 2 (singular or plural)
	def normalize_count( count, default=2 )
		return default if count.nil? # Default to plural
		if /^(#{PL_count_one})$/i =~ count.to_s ||
				Linguistics::classical? &&
				/^(#{PL_count_zero})$/ =~ count.to_s
			return 1
		else
			return default
		end
	end


	### Do normal/classical switching and match capitalization in <tt>inflected</tt> by
	### examining the <tt>original</tt> input.
	def postprocess( original, inflected )
		inflected.sub!( /([^|]+)\|(.+)/ ) {
			Linguistics::classical? ? $2 : $1
		}

		case original
		when "I"
			return inflected
		when /^[A-Z]+$/
			return inflected.upcase
		when /^[A-Z]/
			# Can't use #capitalize, as it will downcase the rest of the string,
			# too.
			inflected[0,1] = inflected[0,1].upcase
			return inflected
		else
			return inflected
		end
	end

	### Transform the specified number of units-place numerals into a
	### word-phrase at the given number of +thousands+ places.
	def to_units( units, thousands=0 )
		return Units[ units ] + to_thousands( thousands )
	end


	### Transform the specified number of tens- and units-place numerals into a
	### word-phrase at the given number of +thousands+ places.
	def to_tens( tens, units, thousands=0 )
		unless tens == 1
			return Tens[ tens ] + ( tens.nonzero? && units.nonzero? ? '-' : '' ) +
				to_units( units, thousands )
		else
			return Teens[ units ] + to_thousands( thousands )
		end
	end


	### Transform the specified number of hundreds-, tens-, and units-place
	### numerals into a word phrase. If the number of thousands (+thousands+) is
	### greater than 0, it will be used to determine where the decimal point is
	### in relation to the hundreds-place number.
	def to_hundreds( hundreds, tens=0, units=0, thousands=0, joinword=" and " )
		joinword = ' ' if joinword.empty?
		if hundreds.nonzero?
			return to_units( hundreds ) + " hundred" +
				(tens.nonzero? || units.nonzero? ? joinword : '') +
				to_tens( tens, units ) +
				to_thousands( thousands )
		elsif tens.nonzero? || units.nonzero?
			return to_tens( tens, units ) + to_thousands( thousands )
		else
			return nil
		end
	end

	### Transform the specified number into one or more words like 'thousand',
	### 'million', etc. Uses the thousands (American) system.
	def to_thousands( thousands=0 )
		parts = []
		(0..thousands).step( Thousands.length - 1 ) {|i|
			if i.zero?
				parts.push Thousands[ thousands % (Thousands.length - 1) ]
			else
				parts.push Thousands.last
			end
		}

		return parts.join(" ")
	end


	### Return the specified number +num+ as an array of number phrases.
	def number_to_words( num, config )
		return [config[:zero]] if num.to_i.zero?
		chunks = []

		# Break into word-groups if groups is set
		if config[:group].nonzero?

			# Build a Regexp with <config[:group]> number of digits. Any past
			# the first are optional.
			re = Regexp::new( "(\\d)" + ("(\\d)?" * (config[:group] - 1)) )

			# Scan the string, and call the word-chunk function that deals with
			# chunks of the found number of digits.
			num.to_s.scan( re ) {|digits|
				debug_msg "   digits = #{digits.inspect}"
				fn = NumberToWordsFunctions[ digits.size ]
				numerals = digits.flatten.compact.collect {|i| i.to_i}
				debug_msg "   numerals = #{numerals.inspect}"
				chunks.push fn.call( config[:zero], *numerals ).strip
			}
		else
			phrase = num.to_s
			phrase.sub!( /\A\s*0+/, '' )
			mill = 0

			# Match backward from the end of the digits in the string, turning
			# chunks of three, of two, and of one into words.
			mill += 1 while
				phrase.sub!( /(\d)(\d)(\d)(?=\D*\Z)/ ) {
					words = to_hundreds( $1.to_i, $2.to_i, $3.to_i, mill, 
										 config[:and] )
					chunks.unshift words.strip.squeeze(' ') unless words.nil?
					''
				}				

			phrase.sub!( /(\d)(\d)(?=\D*\Z)/ ) {
				chunks.unshift to_tens( $1.to_i, $2.to_i, mill ).strip.squeeze(' ')
				''
			}
			phrase.sub!( /(\d)(?=\D*\Z)/ ) {
				chunks.unshift to_units( $1.to_i, mill ).strip.squeeze(' ')
				''
			}
		end

		return chunks
	end

	### Return the specified number as english words. One or more configuration
	### values may be passed to control the returned String:
	### 
	### [<b>:group</b>]
	###   Controls how many numbers at a time are grouped together. Valid values
	###   are <code>0</code> (normal grouping), <code>1</code> (single-digit 
	###   grouping, e.g., "one, two, three, four"), <code>2</code> 
	###   (double-digit grouping, e.g., "twelve, thirty-four", or <code>3</code>
	###   (triple-digit grouping, e.g., "one twenty-three, four").
	### [<b>:comma</b>]
	###   Set the character/s used to separate word groups. Defaults to 
	###   <code>", "</code>.
	### [<b>:and</b>]
	###   Set the word and/or characters used where <code>' and ' </code>(the 
	###   default) is normally used. Setting <code>:and</code> to 
	###   <code>' '</code>, for example, will cause <code>2556</code> to be 
	###   returned as "two-thousand, five hundred fifty-six" instead of 
	###   "two-thousand, five hundred and fifty-six".
	### [<b>:zero</b>]
	###   Set the word used to represent the numeral <code>0</code> in the 
	###   result. <code>'zero'</code> is the default.
	### [<b>:decimal</b>]
	###   Set the translation of any decimal points in the number; the default
	###   is <code>'point'</code>.
	### [<b>:asArray</b>]
	###   If set to a true value, the number will be returned as an array of
	###   word groups instead of a String.
	def numwords( number, hashargs={} )
		num = number.to_s
		config = NumwordDefaults.merge( hashargs )
		raise "Bad chunking option: #{config[:group]}" unless
			config[:group].between?( 0, 3 )

		# Array of number parts: first is everything to the left of the first
		# decimal, followed by any groups of decimal-delimted numbers after that
		parts = []

		# Wordify any sign prefix
		sign = (/\A\s*\+/ =~ num) ? 'plus' : (/\A\s*\-/ =~ num) ? 'minus' : ''

		# Strip any ordinal suffixes
		ord = true if num.sub!( /(st|nd|rd|th)\Z/, '' )

		# Split the number into chunks delimited by '.'
		chunks = if !config[:decimal].empty? then
					 if config[:group].nonzero?
						 num.split(/\./)
					 else
						 num.split(/\./, 2)
					 end
				 else
					 [ num ]
				 end

		# Wordify each chunk, pushing arrays into the parts array
		chunks.each_with_index {|chunk,section|
			chunk.gsub!( /\D+/, '' )

			# If there's nothing in this chunk of the number, set it to zero
			# unless it's the whole-number part, in which case just push an
			# empty array.
			if chunk.empty?
				if section.zero?
					parts.push []
					next 
				end
			end

			# Split the number section into wordified parts unless this is the
			# second or succeeding part of a non-group number
			unless config[:group].zero? && section.nonzero?
				parts.push number_to_words( chunk, config )
			else
				parts.push number_to_words( chunk, config.merge(:group => 1) )
			end					
		}

		debug_msg "Parts => #{parts.inspect}"
		
		# Turn the last word of the whole-number part back into an ordinal if
		# the original number came in that way.
		if ord && !parts[0].empty?
			parts[0][-1] = ordinal( parts[0].last )
		end

		# If the caller's expecting an Array return, just flatten and return the
		# parts array.
		if config[:asArray]
			unless sign.empty?
				parts[0].unshift( sign )
			end
			return parts.flatten
		end

		# Catenate each sub-parts array into a whole number part and one or more
		# post-decimal parts. If grouping is turned on, all sub-parts get joined
		# with commas, otherwise just the whole-number part is.
		if config[:group].zero?
			if parts[0].size > 1

				# Join all but the last part together with commas
				wholenum = parts[0][0...-1].join( config[:comma] )

				# If the last part is just a single word, append it to the
				# wholenum part with an 'and'. This is to get things like 'three
				# thousand and three' instead of 'three thousand, three'.
				if /^\s*(\S+)\s*$/ =~ parts[0].last
					wholenum += config[:and] + parts[0].last
				else
					wholenum += config[:comma] + parts[0].last
				end
			else
				wholenum = parts[0][0]
			end
			decimals = parts[1..-1].collect {|part| part.join(" ")}

			debug_msg "Wholenum: #{wholenum.inspect}; decimals: #{decimals.inspect}"

			# Join with the configured decimal; if it's empty, just join with
			# spaces.
			unless config[:decimal].empty?
				return sign + ([ wholenum ] + decimals).
					join( " #{config[:decimal]} " ).strip
			else
				return sign + ([ wholenum ] + decimals).
					join( " " ).strip
			end
		else
			return parts.compact.
				separate( config[:decimal] ).
				delete_if {|el| el.empty?}.
				join( config[:comma] ).
				strip
		end
	end
	def_lprintf_formatter :NUMWORDS, :numwords


	### Transform the given +number+ into an ordinal word. The +number+ object
	### can be either an Integer or a String.
	def ordinal( number )
		case number
		when Integer
			return number.to_s + (Nth[ number % 100 ] || Nth[ number % 10 ])

		else
			return number.to_s.sub( /(#{OrdinalSuffixes})\Z/ ) { Ordinals[$1] }
		end
	end
	def_lprintf_formatter :ORD, :ordinal


	### Format the given +fmt+ string by replacing %-escaped sequences with the
	### result of performing a specified operation on the corresponding
	### argument, ala Kernel.sprintf.
	### %PL::
	###   Plural.
	### %A, %AN::
	###   Prepend indefinite article.
	### %NO::
	###   Zero-quantified phrase.
	### %NUMWORDS::
	###   Convert a number into the corresponding words.
	### %CONJUNCT::
	###   Conjunction.
	def lprintf( fmt, *args )
		fmt.to_s.gsub( /%([A-Z_]+)/ ) do |match|
			op = $1.to_s.upcase.to_sym
			if self.lprintf_formatters.key?( op )
				arg = args.shift
				self.lprintf_formatters[ op ].call( arg )
			else
				raise "no such formatter %p" % op
			end
		end
	end

end # module Linguistics::EN


### Add the #separate and #separate! methods to Array.
class Array

	### Returns a new Array that has had a new member inserted between all of
	### the current ones. The value used is the given +value+ argument unless a
	### block is given, in which case the block is called once for each pair of
	### the Array, and the return value is used as the separator.
	def separate( value=:__no_arg__, &block )
		ary = self.dup
		ary.separate!( value, &block )
		return ary
	end

	### The same as #separate, but modifies the Array in place.
	def separate!( value=:__no_arg__ )
		raise ArgumentError, "wrong number of arguments: (0 for 1)" if
			value == :__no_arg__ && !block_given?

		(1..( (self.length * 2) - 2 )).step(2) do |i|
			if block_given?
				self.insert( i, yield(self[i-1,2]) )
			else
				self.insert( i, value )
			end
		end
		self
	end
		
end

