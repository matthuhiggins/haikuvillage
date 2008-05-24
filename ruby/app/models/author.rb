class Author < ActiveRecord::Base
  has_many :favorites, :through => :haiku_favorites, :source => :haiku
  has_many :haiku_favorites
  has_many :haikus
  
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_presence_of :password
  
  def self.authenticate(username, password)
    find_or_initialize_by_username(username).authenticate(password)
  end
  
  def authenticate(password)
    send(new_record? ? :authenticate_new : :authenticate_cached, password)
  end
  
  private
    def authenticate_new(password)
      if Twitter.authenticate(username, password)
        self.password = password
        save
        self
      end
    end
    
    def authenticate_cached(password)
      if self.password == password
        self
      elsif Twitter.authenticate(self.username, password)
        update_attribute(:password, password)
        self
      end
    end
end
