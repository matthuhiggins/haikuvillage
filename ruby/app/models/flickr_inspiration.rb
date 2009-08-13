class FlickrInspiration < ActiveRecord::Base
  class << self
    def collect
      response = Net::HTTP.get(flickr_host, interestingness_path)
      json = ActiveSupport::JSON.decode(response)
      photos = json['photos']['photo']
      photos.each { |photo_json| create_from_json(photo_json) }
    end
    
    private
      def interestingness_path
        now = 2.days.ago.utc
        date = now.strftime('%Y-%m-%d')
        "/services/rest/?method=flickr.interestingness.getList&api_key=#{api_key}&per_page=10&date=#{date}&format=json&nojsoncallback=1"
      end
      
      def flickr_host
        'api.flickr.com'
      end
      
      def api_key
        '3caa3374c4ee9c68a0873e5bd3d0cfac'
      end
      
      def create_from_json(json)
        unless exists?(:photo_id => json['id'])
          create!(
            :title        => json['title'],
            :farm_id      => json['farm'],
            :server_id    => json['server'],
            :photo_id     => json['id'],
            :secret       => json['secret']
          )
        end
      end
  end

  inspired_by :flickr

  def to_url(size_type = '')
    "http://farm#{farm_id}.static.flickr.com/#{server_id}/#{photo_id}_#{secret}#{size_type}.jpg"
  end
  
  def thumbnail
    to_url('_m')
  end
  
  def small
    to_url('_s')
  end
end