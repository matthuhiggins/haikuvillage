$:.unshift(File.dirname(__FILE__))

require 'lib/link_to_block'

ActionView::Base.class_eval do
  include HaikuView::Helpers::UrlBlockHelper
  include HaikuView::Helpers::PrototypeBlockHelper
end