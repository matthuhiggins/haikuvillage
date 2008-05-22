class Twitter
  STATUS_UPDATE = "http://twitter.com/statuses/update.xml"
  AUTHENTICATE = "http://twitter.com/account/verify_credentials.xml"
  
  class << self
    def authenticate(user)
      twitter_head(AUTHENTICATE, user) do |code, data|
        code == 200
      end
    end
    
    def create_haiku(haiku)
      twitter_post(STATUS_UPDATE, haiku.user, {'status' => "@haikuvillage #{haiku.text}"}) do |code, data|
        raise StandardError unless code == 200
        haiku[:twitter_status_id] = data['id'].to_i
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
          def twitter_#{verb}(path, user, data = nil, &block)
            request = new_request(:#{verb}, path)
            request.basic_auth user.username, user.password
            request.set_form_data(data, ';') if data
            make_request(request, URI.parse(path), &block)
          end
        EVAL
      end
  end
end