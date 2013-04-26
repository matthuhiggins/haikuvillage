module Application
  module FacebookContext
    extend ActiveSupport::Concern

    included do
      before_filter :configure_facebook_author, if: :facebook_connected?

      helper_method :facebook_connected?
    end

    private
      def author_from_facebook
        Author.find_or_create_by_facebook(facebook_uid, facebook_graph)
      end

      def configure_facebook_author
        if author = current_author
          Author.migrate(author, author_from_facebook) if author.fb_uid.nil?
        else
          login(author_from_facebook)
        end
      end

      def facebook_graph
        @facebook_graph ||= begin
          if facebook_connected?
            Koala::Facebook::API.new(facebook_cookie["access_token"])
          end
        end
      end

      def facebook_uid
        facebook_cookie["user_id"]
      end

      def facebook_connected?
        facebook_cookie && facebook_cookie["access_token"]
      end

      def facebook_cookie
        return @facebook_cookie if instance_variable_defined?(:@facebook_cookie)
        @facebook_cookie ||= facebook_oauth.get_user_info_from_cookie(cookies)
      rescue Koala::Facebook::OAuthTokenRequestError
        nil
      end

      def facebook_oauth
        @facebook_oauth ||= Koala::Facebook::OAuth.new(FacebookConfig.app_id, FacebookConfig.secret)
      end
  end
end