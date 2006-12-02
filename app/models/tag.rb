class Tag < ActiveRecord::Base
  has_many :haiku_tags
  has_many :haikus, :through => :haiku_tags
  
  def self.get_popular_tags
    self.get_tags(:use_count, 5)
  end
  
  def self.get_recent_tags
    self.get_tags(:created_at, 5)
  end
  
  private
  
  def self.get_tags(order_by, limit)
    Tag.find_by_sql %{
        select *
        from tags
        order by #{order_by}
        limit #{limit}}
  end
end