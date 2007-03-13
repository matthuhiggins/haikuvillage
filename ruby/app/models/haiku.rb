class Haiku < ActiveRecord::Base
  after_destroy :destroy_index
  after_save :save_index

  belongs_to :user
  has_many :haiku_tags
  has_many :tags, :through => :haiku_tags
  has_many :haiku_favorites, :dependent => :delete_all
  has_many :happy_users, :through => :haiku_favorites, :source => :user
  has_many :comments, :class_name => "HaikuComment"

  validates_presence_of :line1, :line2, :line3, :user_id

  def validate
    valid_syllable_counts = [5, 7, 5]
    for line_number in 1..3
      if read_attribute("line#{line_number}") == nil
        errors.add("Missing line #{line_number}")
      else
        line = Line.new(read_attribute("line#{line_number}"))
        if line.syllables != valid_syllable_counts[line_number-1]
          errors.add("syllable count on line #{line_number}")        
        end
      end
    end
  end
  
  def text
    (1..3).collect{|line_number| read_attribute("line#{line_number}")}.join("\n")
  end
  
  def text=(haiku_text)
    lines = haiku_text.split("\n")
    (1..3).each do |line_number|
      write_attribute("line#{line_number}", lines[line_number-1])
    end
  end

  private
  
  def destroy_index  
  end
  
  def save_index  
  end
  
  def get_line_text(line_number)
    read_attribute("line#{number}")
  end
end