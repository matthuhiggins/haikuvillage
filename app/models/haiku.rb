class Haiku < ActiveRecord::Base
  validates_presence_of :title, :line1, :line2, :line3
  has_many :haiku_tags
  has_many :tags, :through => :haiku_tags

  
  def self.from_haiku_view(haiku_view)
    h = self.new
    h.title = haiku_view.title
    h.line1, h.line2, h.line3 = haiku_view.lines.map {|line| line.text }
    h
  end   
  
  def self.get_haikus
    find(:all)
  end
end
