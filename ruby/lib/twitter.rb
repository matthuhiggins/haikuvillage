class Twitter
  STATUS_UPDATE = "http://twitter.com/statuses/update.xml"
  AUTHENTICATE = "http://twitter.com/account/verify_credentials.xml"
  
  class AuthenticationError < StandardError
  end
  
  class << self
    def authenticate(username, password)
      twitter_head(AUTHENTICATE, username, password) { |code, data| code == 200 }
    end
    
    def tweet(haiku)
      author = haiku.author
      formatted_text = ERB::Util.h(haiku.terse)
      parameters = {'source' => 'haikuvillage', 'status' => "#haiku #{formatted_text}"}
      twitter_post(STATUS_UPDATE, author.twitter_username, author.twitter_password, parameters) do |code, data|
        raise AuthenticationError if code == 401
      end
    end
    
    private
      def new_request(verb, url)
        Net::HTTP.const_get(verb.to_s.capitalize).new(url)
      end
      
      def make_request(request, url, &block)
        response = Net::HTTP.new(url.host, url.port).start { |http| http.request(request) }
        response_data = XmlSimple.xml_in(response.body, 'keeproot' => false) if response.body
        
        yield(*[response.code[0..2].to_i, response_data].slice(0, block.arity))
      end
    
      [:get, :post, :put, :delete, :head].each do |verb|
        class_eval(<<-EVAL, __FILE__, __LINE__)
          def twitter_#{verb}(path, username, password, data = nil, &block)
            request = new_request(:#{verb}, path)
            request.basic_auth username, password
            request.set_form_data(data, ';') if data
            make_request(request, URI.parse(path), &block)
          end
        EVAL
      end
  end
end