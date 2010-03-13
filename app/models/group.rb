class Group < ActiveRecord::Base
  has_many :haikus, :dependent => :nullify
  has_many :memberships
  has_many :authors, :through => :memberships
  
  validates_presence_of :name, :description
  validates_uniqueness_of :name

  def self.search(text)
    return scoped({}) if text.blank?

    text.split.inject(scoped({})) do |scope, word|
      scope.scoped :conditions => ["groups.name like :word or groups.description like :word", {:word => "%#{word}%"}] 
    end
  end
  
  def add_member(author)
    add_membership author, Membership::MEMBER
  end
  
  def add_admin(author)
    add_membership author, Membership::ADMIN
  end
  
  def invite_author(author)
    add_membership author, Membership::INVITED
    Mailer.deliver_group_invitation(author, self)
  end
  
  def reject_invitation(author)
    memberships.find_by_author_id(author).destroy
  end
  
  def apply_for_membership(author)
    if add_membership(author, Membership::APPLIED)
      Mailer.deliver_group_application(author, self)
    end
  end
  
  def accept_application(application)
    application.update_attribute(:standing, Membership::MEMBER)
  end
    
  private
    # Returns true if anything changed
    def add_membership(author, standing)
      if membership = memberships.find_by_author_id(author)
        membership.update_attribute(:standing, standing)
        membership.changed?
      else
        membership = Membership.new(:group => self, :author => author)
        membership.standing = standing
        memberships << membership
        true
      end
    end
end