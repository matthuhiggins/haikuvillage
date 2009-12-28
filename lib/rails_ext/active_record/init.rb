$:.unshift(File.dirname(__FILE__))

require 'lib/inspirations'

ActiveRecord::Base.class_eval do
  include HaikuRecord::Inspirations
end

require 'lib/data_types'