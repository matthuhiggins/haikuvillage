require 'haiku/line'

class Haiku < ActiveRecord::Base
  include Haiku::Conversational
  
  belongs_to :author
  belongs_to :subject
  has_many :favorites, :dependent => :delete_all
  has_many :happy_authors, :through => :favorites, :source => :author
    
  scope :recent, order('haikus.id desc').includes([:conversation, :author])
  
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
  validate :valid_syllables?, on: :create

  class << self
    def search(text)
      text.split.inject(scoped({:include => [:conversation, :author, :subject]})) do |scope, word|
        scope.scoped :conditions => ["haikus.text like :word or subjects.name like :word", {:word => "%#{word}%"}] 
      end
    end
  
    def find_by_param(param)
      if param =~ /^(\d+)/
        find($1)
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def global_feed
      active_authors = Author.recently_updated.limit(10)
      where(id: active_authors.map(&:latest_haiku_id)).includes(:conversation, :author).order('id desc')
    end
  end
  
  
  VALID_SYLLABLES = [5, 7, 5]
  
  def valid_syllables?
    if lines.size != VALID_SYLLABLES.size
      errors.add("Need three lines")
    else
      VALID_SYLLABLES.zip(lines).each_with_index do |(expected, line), row|
        syllable_count = line.split.sum(&:syllables)
        if expected =! syllable_count
          errors.add(:base, "line #{row} has #{syllable_count} syllables") 
        end
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

  def lines
    text.split(/\n/)
  end

  def terse
    text.gsub(/\n/, ' / ')
  end

  def to_param
    "#{id}-#{lines.first.parameterize}"
  end
end