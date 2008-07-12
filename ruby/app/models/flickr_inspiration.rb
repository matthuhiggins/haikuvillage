class FlickrInspiration < ActiveRecord::Base
  belongs_to :conversation
  
  def to_url(size_type = '')
    # size = small ? '_m' : ''
    "http://farm#{farm_id}.static.flickr.com/#{server_id}/#{photo_id}_#{secret}#{size_type}.jpg"
  end
  
  def thumbnail
    to_url('_m')
  end
end