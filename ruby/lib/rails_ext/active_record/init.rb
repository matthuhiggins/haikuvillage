$:.unshift(File.dirname(__FILE__))

require 'lib/foreign_key'
require 'lib/inspirations'

ActiveRecord::Base.class_eval do
  include HaikuRecord::Inspirations
end

ActiveRecord::Migration.class_eval do
  extend HaikuRecord::ForeignKey
end