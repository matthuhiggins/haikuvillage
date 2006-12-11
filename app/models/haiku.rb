class Haiku < ActiveRecord::Base
  belongs_to :user
  has_many :haiku_tags
  has_many :tags, :through => :haiku_tags
  has_many :haiku_favorites
  has_many :happy_users, :through => :haiku_favorites, :source => :user

  validates_presence_of :title, :line1, :line2, :line3

  def validate
    valid_syllable_counts = [5, 7, 5]
    [1..3].collect do |line_number|
      if read_attribute("line#{line_number}") == nil
        errors.add("Missing line #{line_number}")
      elsif Line.new(line).syllables != valid_syllable_counts[line_number-1]
          errors.add("Invalid syllable count on line #{line_number}")        
      end
    end
  end
  
  def text
    [1..3].collect{|line_number| read_attribute("line#{line_number}")}.join("\n")
  end
  
  def text=(haiku_text)
    lines = haiku_text.split("\n")
    [1..3].each{|line_number| write_attribute("line#{line_number}", lines[line_number])}
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
  
  private
  
  def get_line_text(line_number)
    read_attribute("line#{number}")
  end  
end