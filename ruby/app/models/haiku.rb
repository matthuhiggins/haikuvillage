class Haiku < ActiveRecord::Base
  class Line
    attr_reader :words

    def initialize(text)
      @words = text.split.map{ |word| Word.new(word) }
    end

    def syllables
      words.sum &:syllables
    end
  end

  belongs_to :author
  belongs_to :subject
  belongs_to :conversation
  has_many :haiku_favorites, :dependent => :delete_all
  has_many :happy_authors, :through => :haiku_favorites, :source => :author
    
  named_scope :recent, :order => 'haikus.id desc'
  named_scope :top_favorites, :order => 'favorited_count_week desc, favorited_count_total desc', :conditions => 'favorited_count_total > 0'
  named_scope :most_viewed, :order => 'view_count_week desc, view_count_total desc', :conditions => 'view_count_total > 0'
  
  after_create do |haiku|
    Author.update_counters(haiku.author_id, :haikus_count_week => 1, :haikus_count_total => 1)
    Subject.update_counters(haiku.subject_id, :haikus_count_week => 1, :haikus_count_total => 1) if haiku.subject_id
  end
  
  attr_accessor :conversing_with
  before_create :construct_conversation
  
  before_destroy do |haiku|
    Author.update_counters(haiku.author_id, :haikus_count_total => -1)
    Subject.update_counters(haiku.subject_id, :haikus_count_total => -1) if haiku.subject_id
  end
  
  validates_presence_of :author_id
  validates_presence_of :text
  validate :valid_syllables?
  
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
    return if name.blank?
    name = name.gsub(/[^\w| ]/, '').chomp
    self.subject = Subject.find_or_create_by_name(name) unless name.blank?
    self[:subject_name] = name
  end
  
  def construct_conversation
    unless conversing_with.nil? || conversing_with.empty?
      transaction do
        other_haiku = Haiku.find(conversing_with)
        if other_haiku.conversation.nil?
          other_haiku.create_conversation
          other_haiku.save
        end
        self.conversation = other_haiku.conversation
      end
    end
  end
end