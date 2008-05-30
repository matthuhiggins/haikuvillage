$:.unshift(File.dirname(__FILE__))

require 'lib/link_to_block'
require 'lib/google_asset_tag_helper'

ActionView::Base.class_eval do
  include HaikuView::Helpers::UrlBlockHelper
  include HaikuView::Helpers::PrototypeBlockHelper
  include HaikuView::Helpers::GoogleAssetTagHelper
end