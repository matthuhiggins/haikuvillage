require 'application_controller/login_filter'

ActionController::Base.class_eval do
  include LoginFilter
  include ExceptionLoggable
end