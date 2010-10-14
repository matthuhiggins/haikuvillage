class Author < ActiveRecord::Base
  include Author::Authenticated
  include Author::Friendly
  include Author::Remembered
  include Author::Bipolar

  has_many :favorites
  has_many :favorite_haikus, :through => :favorites, :source => :haiku
  has_many :haikus
  has_many :messages
  belongs_to :latest_haiku, :class_name => "Haiku"
  
  before_validation :if => :username do |author|
    author.username = author.username.downcase
  end

  is_gravtastic!

  scope :brand_new, :order => 'created_at desc'
  scope :active, :order => 'haikus_count_week desc, haikus_count_total desc', :conditions => 'haikus_count_total > 0'
  scope :popular, :order => 'favorited_count_total desc', :conditions => 'favorited_count_total > 0'
  scope :recently_updated, where('latest_haiku_id is not null').order('latest_haiku_id desc')
  
  validates_presence_of :email, :username
  validates_uniqueness_of :username, :email
  validates_format_of :username, :with => /\A[a-z0-9]+\Z/i, :message => 'can only contain numbers and letters', :on => :create
  
  SubjectSummary = Struct.new(:name, :count)
  def subjects
    records = haikus.count(:group => :subject_name, :conditions => 'subject_name is not null', :order => 'count_all desc')
    records.map { |record| SubjectSummary.new(*record) }
  end
  
  private
    def downcase_username
      self.username = self.username.downcase unless self.username.nil?
    end
end