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
    valid_syllables = [5, 7, 5]
    
    split_lines = text.split(/\n|\r/)
    if split_lines.length != valid_syllables.size
      errors.add("Need three lines")
    else
      input_syllables = split_lines.collect { |line_text| Line.new(line_text).syllables }
      valid_syllables.zip(input_syllables).each_with_index do |pair, line_number|
        errors.add("line #{line_number}") unless pair.first == pair.last
      end
    end
  end
end