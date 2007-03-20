class HaikuSearch
  
  def self.get_haikus_by_tag_name(tag_name)
    Tag.find(:first, :conditions => {:name => tag_name}).haikus
  end
end