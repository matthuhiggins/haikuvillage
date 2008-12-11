class Author < ActiveRecord::Base
  has_many :favorites, :through => :haiku_favorites, :source => :haiku
  has_many :haiku_favorites
  has_many :haikus

  has_attached_file :avatar, :default_url => "/images/default_avatars/:style.png",
                             :styles => { :large => "64x64>", :medium => "32x32>", :small => "16x16>",  }

  named_scope :brand_new, :order => 'created_at desc'
  named_scope :active, :order => 'haikus_count_week desc, haikus_count_total desc', :conditions => 'haikus_count_total > 0'
  named_scope :popular, :order => 'favorited_count_total desc', :conditions => 'favorited_count_total > 0'
  named_scope :search, lambda { |query| {:conditions => ['username like ?', "#{query}%"]} }
  
  validates_presence_of :email, :username, :password, :on => :create
  validates_uniqueness_of :username, :on => :create
  validates_format_of :username, :with => /\A[a-z0-9]+\Z/i, :message => 'can only contain numbers and letters', :on => :create
  
  def self.authenticate(username, password)
    find_or_initialize_by_username(username).authenticate(password)
  end
  
  def authenticate(password)
    self if self.password == password
  end
end