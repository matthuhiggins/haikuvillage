class Haiku < ActiveRecord::Base
  belongs_to :user
  has_many :haiku_tags
  has_many :tags, :through => :haiku_tags
  has_many :haiku_favorites
  has_many :happy_users, :through => :haiku_favorites, :source => :user

  validates_presence_of :title, :line1, :line2, :line3  

  def validate
    lines = [line1, line2, line3].map {|line| Line.new(line)}
    valid_syllable_counts = [5, 7, 5]
    
    lines.each_index do |index|
      if (lines[index].syllables == valid_syllable_counts[index])
        errors.add_to_base("Invalid syllable count on line #{index+1}") 
      end
    end
  end  

  def text
    [line1, line2, line3].join("\n")
  end
  
  def text=(haiku_text)
    line1, line2, line3 = text.split("\n")
  end
  
  # Search functions
  def self.get_haikus
    Haiku.find(:all)
  end
  
  def self.get_haikus_by_tag_name(tag_name)
    Haiku.find(:all)
  end
  
  def self.get_haikus_by_popularity
    Tag.find(:all,
             :order => "haiku_favorites_count",
             :limit => 10)
  end
  
  def self.get_haikus_by_recent_popularity
  end
  
end