class FlickrInspiration < ActiveRecord::Base
  class << self
    def collect
      
    end
    
    def clense
      delete_all :conversation_id => nil
    end
  end

  inspired_by :flickr

  def to_url(size_type = '')
    "http://farm#{farm_id}.static.flickr.com/#{server_id}/#{photo_id}_#{secret}#{size_type}.jpg"
  end
  
  def thumbnail
    to_url('_m')
  end
end