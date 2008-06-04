$:.unshift(File.dirname(__FILE__))

require 'lib/haiku_listing'
require 'lib/login_filter'

ActionController::Base.class_eval do
  include HaikuController::HaikuListing
  include HaikuController::LoginFilter
  include ExceptionLoggable
end