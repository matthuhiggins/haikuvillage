class Membership < ActiveRecord::Base
  APPLIED = 1
  INVITED = 2
  MEMBER  = 3
  ADMIN   = 4

  belongs_to :group, :counter_cache => true
  belongs_to :author
  
  # default_scope :conditions => {:standing => [MEMBER, ADMIN]}
  named_scope :applied, :conditions => {:standing => APPLIED}
  named_scope :invited, :conditions => {:standing => INVITED}
  named_scope :members, :conditions => {:standing => MEMBER}
  named_scope :admins, :conditions => {:standing => ADMIN}
  
  def admin?
    self.standing == ADMIN
  end
end