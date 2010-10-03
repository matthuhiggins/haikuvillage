require 'haiku/line'

class Haiku < ActiveRecord::Base
  include Haiku::Conversational
  
  belongs_to :author
  belongs_to :subject
  has_many :favorites, :dependent => :delete_all
  has_many :happy_authors, :through => :favorites, :source => :author
    
  scope :recent, :order => 'haikus.id desc', :include => [:conversation, :author]
  
  after_create do |haiku|
    Author.update_counters(haiku.author_id, :haikus_count_week => 1, :haikus_count_total => 1)
    Subject.update_counters(haiku.subject_id, :haikus_count_week => 1, :haikus_count_total => 1) if haiku.subject_id
    haiku.author.update_attribute(:latest_haiku_id, haiku.id)
  end
  
  before_destroy do |haiku|
    Author.update_counters(haiku.author_id, :haikus_count_total => -1)
    Subject.update_counters(haiku.subject_id, :haikus_count_total => -1) if haiku.subject_id
  end
  
  validates_presence_of :text, :on => :create
  validate_on_create :valid_syllables?
  
  def self.search(text)
    text.split.inject(scoped({:include => [:conversation, :author, :subject]})) do |scope, word|
      scope.scoped :conditions => ["haikus.text like :word or subjects.name like :word", {:word => "%#{word}%"}] 
    end
  end
  
  VALID_SYLLABLES = [5, 7, 5]
  
  def valid_syllables?
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
  
  def subject_name=(name)
    name = name.gsub(/[^\w| ]/, '').chomp.downcase
    if name.blank?
      self[:subject_name] = nil
    else
      self[:subject_name] = name
      self.subject = Subject.find_or_create_by_name(name)
    end
  end
  
  def terse
    text.gsub(/\n/, ' / ')
  end
end