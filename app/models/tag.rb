class Tag < ActiveRecord::Base
  has_many :haiku_tags
  has_many :haikus, :through => :haiku_tags

  validates_presence_of :name
  
  def self.add_haiku_tag(tag_name, haiku)
    tag = create_or_get_tag(tag_name)
    tag.haiku_tags.create(:haiku => haiku)
    tag.save!
    tag
  end
  
  def self.create_or_get_tag(tag_name)
    Tag.find(:first, :conditions => ["name = ?", tag_name]) || Tag.create!(:name => tag_name)
  end
    
  def self.remove_haiku_tag(tag_name, haiku)
  end
    

  def self.get_popular_tags(last = nil)
    Tag.find(:all,
             :order => "haiku_tags_count",
             :limit => 10)
  end
  
  def self.get_recent_tags
    Tag.find(:all,
             :conditions => ["created_at > ?", 1.week.ago],
             :order => "haiku_tags_count",
             :limit => 10)
  end
end