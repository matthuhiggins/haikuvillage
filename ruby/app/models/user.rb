require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :favorites, :through => :haiku_favorites, :source => :haiku
  has_many :haiku_favorites
  has_many :haikus
  has_many :group_users, :dependent => :delete_all
  has_many :groups, :through => :group_users
  
  attr_accessor :password_confirmation

  validates_presence_of :username
  validates_uniqueness_of :username  
  validates_presence_of :email 
  validates_confirmation_of :password
  validates_presence_of :password

  def validate
    errors.add_to_base("Missing password") if hashed_password.blank?
  end  
  
  def self.authenticate(username, password)
    user = self.find_by_username(username)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
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
  
  def is_subscribed_to( group )
    self.groups.include?(group)
  end
  
  def administers( group )
    is_subscribed_to( group ) && self.group_users.find(:first, :conditions => ["group_id = ?", group.id]).user_type == "admin"
  end
  
  def join( group )
    self.groups << group unless is_subscribed_to(group)
  end
  
  def leave( group )
    if is_subscribed_to(group)
      GroupUser.delete_all("user_id = #{self.id} and group_id = #{group.id}")
      #self.group_users.find_by_group_id(group).destroy
    end
  end
  
  def admin_groups
    self.group_users.find(:all, :conditions => ["user_type = 'admin'"]).map{|group_user| group_user.group}
  end
  
  def non_admin_groups
    self.group_users.find(:all, :conditions => ["user_type <> 'admin'"]).map{|group_user| group_user.group}
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
