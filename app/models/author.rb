class Author < ActiveRecord::Base
  include Author::Authenticated
  include Author::Friendly
  include Author::Remembered
  include Author::Bipolar

  has_many :favorites
  has_many :favorite_haikus, :through => :favorites, :source => :haiku
  has_many :haikus
  has_many :messages
  has_many :subjects, through: :haikus
  belongs_to :latest_haiku, :class_name => "Haiku"
  
  before_validation :if => :username do |author|
    author.username = author.username.downcase
  end

  scope :brand_new, :order => 'created_at desc'
  scope :active, :order => 'haikus_count_week desc, haikus_count_total desc', :conditions => 'haikus_count_total > 0'
  scope :popular, :order => 'favorited_count_total desc', :conditions => 'favorited_count_total > 0'
  scope :recently_updated, where('latest_haiku_id is not null').order('latest_haiku_id desc')
  
  validates_presence_of :email, :username
  validates_uniqueness_of :username, :email
  validates_format_of :username, :with => /\A[a-z0-9]+\Z/i, :message => 'can only contain numbers and letters', :on => :create
  
  def subject_summaries
    records = haikus.where('subject_id is not null').order('count_all desc').group(:subject_id).count
    records.map do |(subject_id, haiku_count)|
      [Subject.find(subject_id), haiku_count]
    end
  end
  
  private
    def downcase_username
      self.username = self.username.downcase unless self.username.nil?
    end
end