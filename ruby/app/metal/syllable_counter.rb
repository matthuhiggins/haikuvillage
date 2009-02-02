class SyllableCounter
  def self.call(env)
    if env["REQUEST_URI"] =~ /^\/syllables\?words=(.*)/
      words = $1.split("-").map { |word| URI.unescape(word) }
      [200, {}, words.map { |word| {:text => word, :syllables => word.syllables} }.to_json ]
      # [200, {"Content-Type" => "application/json"}, words.map { |word| {:text => word, :syllables => word.syllables}.to_json } ]
    else
      [404, {"Content-Type" => "text/html"}, "Not Found"]
    end
  end
end