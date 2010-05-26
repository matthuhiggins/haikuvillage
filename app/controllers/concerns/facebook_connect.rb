module Concerns::FacebookConnect
  def self.included(controller)
    controller.class_eval do
      extend ActiveSupport::Memoizable
      memoize :facebook_cookie
      helper_method :facebook_connected?, :facebook_uid, :facebook_author
    end
  end

  private
    def facebook_cookie
      return unless (cookie = cookies["fbs_#{Facebook.app_id}"])

      cookie = cookie.gsub(/^\"|\"$/, '')
      hash = Rack::Utils::parse_query(cookie)
      sorted_pairs = hash.sort
    
      payload = ''
      sorted_pairs.each do |key, value|
        if key != 'sig'
          payload += "#{key}=#{value}"
        end
      end
    
      md5 = Digest::MD5.hexdigest("#{payload}#{Facebook.secret}")
      if md5 == hash['sig']
        hash
      end
    end

    def facebook_connected?
      facebook_cookie.present?
    end

    def facebook_uid
      facebook_cookie['uid']
    end

    def facebook_author
      if facebook_connected?
        @facebook_author ||= Author.find_or_create_by_fb_uid(facebook_uid)
        @facebook_author.access_token = facebook_cookie['access_token']
        @facebook_author
      end
    end
end