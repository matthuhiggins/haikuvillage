class Haiku < ActiveRecord::Base
  VALID_SYLLABLES = [5, 7, 5]
  
  belongs_to :author
  has_many :haiku_favorites, :dependent => :delete_all
  has_many :happy_authors, :through => :haiku_favorites, :source => :author

  validates_presence_of :author_id
  validates_presence_of :text
  
  named_scope :recent, :order => 'haikus.id desc'
  named_scope :top_favorites, :order => 'favorited_count_week desc', :conditions => "favorited_count_week > 0"
  named_scope :most_viewed, :order => 'view_count_week desc', :conditions => 'view_count_week > 0'
  
  before_create  { |haiku| Twitter.create_haiku(haiku) }
  after_create   { |haiku| Author.update_counters(haiku.author_id, :haikus_count_week => 1, :haikus_count_total => 1) }
  before_destroy { |haiku| Author.update_counters(haiku.author_id, :haikus_count_week => -1, :haikus_count_total => -1) }
  
  def validate    
    line_records = []
    text.each_line { |line_text| line_records << Line.new(line_text) }
    
    if line_records.size != VALID_SYLLABLES.size
      errors.add("Need three lines")
    else
      VALID_SYLLABLES.zip(line_records).each_with_index do |(expected, line_record), line_number|
        errors.add("line #{line_number}") unless expected == line_record.syllables
      end
    end
  end
end