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
      include InstanceMethods
      before_filter :check_login, options
    end
  end
  
  module InstanceMethods
    def check_login
      redirect_to root_url unless session[:username]
    end
  end
end