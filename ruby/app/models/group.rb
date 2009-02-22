class Group < ActiveRecord::Base
  has_many :haikus, :dependent => :nullify
  has_many :memberships
  has_many :authors, :through => :memberships
  
  has_attached_file :logo, :default_url => "/images/default_avatars/:style.png",
                           :styles => { :large => "64x64>", :medium => "32x32>", :small => "16x16>" }

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  define_index do
    indexes :name
    indexes :description
  end

  def can_contribute(author)
    !members_only || memberships.include?(:author_id => author)
  end
  
  def add_author(author)
    add_membership author, Membership::MEMBER
  end
  
  def add_admin(author)
    add_membership author, Membership::ADMIN
  end
  
  def invite_author(author)
    add_membership author, Membership::INVITED
    Mailer.deliver_group_invitation(author, self)
  end
  
  def apply_for_membership(author)
    add_membership author, Membership::APPLIED
    Mailer.deliver_group_application(author, self)
  end
  
  private 
    def add_membership(author, standing)
      unless memberships.exists?(:author_id => author)
        membership = Membership.new(:group => self, :author => author)
        membership.standing = standing
        memberships << membership
      end
    end
end