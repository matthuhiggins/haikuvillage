class Haiku < ActiveRecord::Base
  belongs_to :user
  has_many :haiku_tags
  has_many :tags, :through => :haiku_tags
  has_many :favorites, :through => :haiku_favorites, :source => :haiku

  validates_presence_of :title, :line1, :line2, :line3

  def self.from_haiku_view(haiku_view)
    h = self.new
    h.title = haiku_view.title
    h.line1, h.line2, h.line3 = haiku_view.lines.map {|line| line.text }
    h
  end   
  
  def self.get_haikus
    Haiku.find(:all)
  end
  
  def self.get_haikus_by_tag_name(tag_name)
    Haiku.find(:all,
               :conditions => "poop")
  end    
end