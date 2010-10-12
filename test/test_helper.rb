ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module ActiveSupport
  TestCase.class_eval do
    include ActionMailer::TestHelper
  end
end