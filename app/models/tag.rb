class Tag < ActiveRecord::Base
  has_many :haiku_tags
  has_many :haikus, :through => :haiku_tags
  
  def self.get_popular_tags
    Tag.find_by_sql("select *, count(*) as count from tags t join haiku_tags ht on t.id = ht.tag_id group by name")
  end
end
