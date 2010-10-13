module HaikuController
  module LoginFilter
    extend ActiveSupport::Concern

    private
      def original_login_referrer
        session[:original_login_referrer] || journal_path
      end
      
      def original_login_request
        session[:original_login_request] || journal_path
      end
      
      def redirect_with_login_context
        session[:original_login_referrer] = request.referrer
        session[:original_login_request] = request.request_uri
        yield if block_given?
        redirect_to(register_path)
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

      def prevent_logged_in(options = {})
        before_filter :check_no_login, options
      end
    end
  
    def check_login
      if !current_author
        redirect_with_login_context do
          flash[:notice] = 'You must sign in first'
        end
      end
    end

    def check_no_login
      if current_author
        redirect_to journal_path
      end
    end
  end
end