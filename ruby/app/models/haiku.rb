class Haiku < ActiveRecord::Base
  VALID_SYLLABLES = [5, 7, 5]
  
  belongs_to :user, :counter_cache => true
  has_many :haiku_favorites, :dependent => :delete_all
  has_many :happy_users, :through => :haiku_favorites, :source => :user

  validates_presence_of :user_id
  validates_presence_of :text
  
  named_scope :recent, :order => 'haikus.id desc'
  named_scope :top_favorites, :order => 'favorited_count_total desc', :conditions => "favorited_count_total > 0"
  named_scope :most_viewed, :order => 'view_count_week desc', :conditions => 'view_count_total > 0'
  
  before_create { |haiku| Twitter.create_haiku(haiku) }

  def validate    
    line_records = []
    text.each_line { |line_text| line_records << Line.new(line_text) }
    
    if line_records.length != VALID_SYLLABLES.size
      errors.add("Need three lines")
    else
      VALID_SYLLABLES.zip(line_records).each_with_index do |(expected, line_record), line_number|
        errors.add("line #{line_number}") unless expected == line_record.syllables
      end
    end
  end
end