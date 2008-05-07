class User < ActiveRecord::Base
  has_many :favorites, :through => :haiku_favorites, :source => :haiku
  has_many :haiku_favorites
  has_many :haikus
  
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_presence_of :password
  
  def self.authenticate(username, password)
    http = Net::HTTP.new('twitter.com')
    http.start do |http|
      request = Net::HTTP::Get.new('/account/verify_credentials.xml')
      request.basic_auth username, password
      begin
        response = http.request(request)
        response.value
        if response.code[0..2].to_i == 200
          find_or_create_by_username(:username => username, :password => password)
        end
      rescue
      end
    end
  end
end
