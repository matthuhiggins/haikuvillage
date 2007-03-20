class Haiku < ActiveRecord::Base
  acts_as_ferret :fields => [:text]

  belongs_to :user
  has_many :haiku_tags
  has_many :tags, :through => :haiku_tags
  has_many :haiku_favorites, :dependent => :delete_all
  has_many :happy_users, :through => :haiku_favorites, :source => :user
  has_many :comments, :class_name => "HaikuComment"

  validates_presence_of :user_id

  def validate
    valid_syllable_counts = [5, 7, 5]
    split_lines = text.split("\r\n")
    logger.debug('split lines: ' + split_lines.inspect)
    if split_lines.length != 3
      errors.add("Need three lines")
    else
      for line_index in 0..2
        line = Line.new(split_lines[line_index])
        if line.syllables != valid_syllable_counts[line_index]
          errors.add("line #{line_index} is invalid")
        end
      end
    end
  end  
end