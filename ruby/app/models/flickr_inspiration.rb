class FlickrInspiration  
  def to_url(small = false)
    size = small ? '_m' : ''
    "http://farm#{farm_id}.static.flickr.com/#{server_id}/#{photo_id}_#{secret_id}#{size}.jpg"
  end
end