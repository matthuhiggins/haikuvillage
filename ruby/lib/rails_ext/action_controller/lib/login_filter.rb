module HaikuController
  module LoginFilter
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    module ClassMethods
      # Checks if a user is logged in before performing an action
      # To prevent any action from being run:
      #
      #   MyController < ApplicationController
      #     login_filter
      #   end
      #
      # The same options for ActionController::Filters are available. For example,
      # to only check for logins in the create and destroy actions:
      #
      #   MyController < ApplicationController
      #     login_filter :only => [:create, :destroy]
      #   end
      #
      def login_filter(options = {})
        before_filter :check_login, options
      end
    end
  
    def check_login
      unless session[:username]
        session[:original_login_referrer] = request.referrer
        redirect_to(root_url)
      end
    end

    private
      def original_login_referrer
        session[:original_login_referrer]
      end
  end
end