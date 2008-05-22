$:.unshift(File.dirname(__FILE__))

require 'lib/login_filter'

ActionController::Base.class_eval do
  include LoginFilter
  include ExceptionLoggable
end