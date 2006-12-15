class HaikuSearch
  
  def self.get_haikus
    Haiku.find(:all)
  end
  
  def self.get_haikus_by_tag_name(tag_name)
    Tag.find(:first, :conditions => {:name => tag_name}).haikus
  end
  
  def self.get_haikus_by_popularity
    Tag.find(:all,
             :order => "haiku_favorites_count",
             :limit => 10)
  end
  
  def self.get_haikus_by_recent_popularity
  end
end