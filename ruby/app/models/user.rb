require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :favorites, :through => :haiku_favorites, :source => :haiku
  has_many :haiku_favorites
  has_many :haikus
  
  attr_accessor :password_confirmation

  validates_presence_of :email 
  validates_uniqueness_of :email, :alias
  validates_confirmation_of :password
  validates_presence_of :password

  def validate
    errors.add_to_base("Missing password") if hashed_password.blank?
  end  
  
  def self.authenticate(email, password)
    user = self.find_by_email(email)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end
  
  def self.get_anonymous
    anon = find(:first, :conditions => {:email => "anonymous"})    
    anon = create(:email => "anonymous",
        :alias => "Anonymous",
        :password => "sa",
        :password_confirmation => "sa") unless anon
    anon 
  end
  
  # 'password' is a virtual attribute  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  
  private
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "haiku" + salt  # 'haiku' makes it harder to guess
    Digest::SHA1.hexdigest(string_to_hash)
  end
    
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
end
