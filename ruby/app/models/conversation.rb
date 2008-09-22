class Conversation < ActiveRecord::Base
  has_many :haikus
  has_one :flickr_inspiration
  
  def inspiration
    if inspiration_type.nil?
      nil
    else
      inspiration_klass.first :conditions => {:conversation_id => self.id}
    end
  end
  
  private
    def inspiration_klass
      FlickrInspiration
    end
end