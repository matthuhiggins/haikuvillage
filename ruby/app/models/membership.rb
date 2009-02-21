class Membership < ActiveRecord::Base
  APPLIED = 1
  INVITED = 2
  MEMBER  = 3
  ADMIN   = 4

  belongs_to :group, :counter_cache => true
  belongs_to :author
  
  default_scope :conditions => {:status => [MEMBER, ADMIN]}
  named_scope :applied, :conditions => {:status => APPLIED}
  named_scope :invited, :conditions => {:status => INVITED}
  
  def admin?
    self.status == ADMIN
  end
end