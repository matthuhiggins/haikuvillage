$:.unshift(File.dirname(__FILE__))

require 'lib/foreign_key'

ActiveRecord::Migration.class_eval do
  extend HaikuRecord::ForeignKey
end