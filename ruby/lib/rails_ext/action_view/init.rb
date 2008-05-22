$:.unshift(File.dirname(__FILE__))

require 'lib/link_to_block'

ActionView::Base.class_eval do
  include ActionView::Helpers::UrlBlockHelper
  include ActionView::Helpers::PrototypeBlockHelper
end