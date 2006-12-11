class Haiku < ActiveRecord::Base
  belongs_to :user
  has_many :haiku_tags
  has_many :tags, :through => :haiku_tags
  has_many :haiku_favorites
  has_many :happy_users, :through => :haiku_favorites, :source => :user

  validates_presence_of :title, :line1, :line2, :line3

  def validate
    if (line1 == nil)
      errors.add("Missing first line")
      logger.debug("1st")
    end
    
    if (line2 == nil)
      errors.add("Missing second line")
      logger.debug("2nd")
    end
    
    if (line3 == nil)
      errors.add("Missing third line")
      logger.debug("3rd")
    else
      lines = [line1, line2, line3].map {|line| Line.new(line)}
      valid_syllable_counts = [5, 7, 5]
    
      lines.each_index do |index|
        if (lines[index].syllables != valid_syllable_counts[index])
          errors.add("Invalid syllable count on line #{index+1}") 
          logger.debug("Invalid syllable count on line #{index+1}, #{lines[index].syllables}")
        end
      end
    end
  end
  
  def text
    [read_attribute("line1"), read_attribute("line2"), read_attribute("line3")].join("\n")
  end
  
  def text=(haiku_text)
    lines = haiku_text.split("\n")
    write_attribute("line1", lines[0])
    write_attribute("line2", lines[1])
    write_attribute("line3", lines[2])
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