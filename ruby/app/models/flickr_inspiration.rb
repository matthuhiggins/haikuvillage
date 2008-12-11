class FlickrInspiration < ActiveRecord::Base
  class << self
    def collect
      response = Net::HTTP.get(flickr_host, interestingness_path)
      xml = XmlSimple.xml_in(response, 'keeproot' => false)
      photos_xml = xml['photos']['photo']
      photos_xml.each { |photo_xml| create_from_xml(photo_xml) }
    end
    
    private
      def interestingness_path
        now = 2.days.ago.utc
        date = now.strftime('%Y-%m-%d')
        "/services/rest/?method=flickr.interestingness.getList&api_key=#{api_key}&per_page=10&date=#{date}"
      end
      
      def flickr_host
        'api.flickr.com'
      end
      
      def api_key
        '3caa3374c4ee9c68a0873e5bd3d0cfac'
      end
      
      def create_from_xml(xml)
        create(
          :title        => xml['title'],
          :farm_id      => xml['farm'],
          :server_id    => xml['server'],
          :photo_id     => xml['id'],
          :secret       => xml['secret']) unless exists?(:photo_id => xml['id'])
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