class Haiku < ActiveRecord::Base
  belongs_to :user
  has_many :haiku_favorites, :dependent => :delete_all
  has_many :happy_users, :through => :haiku_favorites, :source => :user

  validates_presence_of :user_id

  def validate
    valid_syllables = [5, 7, 5]
    
    split_lines = text.split(/\n|\r/)
    if split_lines.length != valid_syllables.size
      errors.add("Need three lines")
    else
      input_syllables = split_lines.collect { |line_text| Line.new(line_text).syllables }
      valid_syllables.zip(input_syllables).each_with_index do |(expected, actual), line_number|
        errors.add("line #{line_number}") unless expected == actual
      end
    end
  end
end