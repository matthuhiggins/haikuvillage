class Group < ActiveRecord::Base
  has_many :haikus
  has_many :memberships
  has_many :authors, :through => :memberships
  
  has_attached_file :avatar, :default_url => "/images/default_avatars/:style.png",
                             :styles => { :large => "64x64>", :medium => "32x32>", :small => "16x16>" }

  validates_presence_of :name

  def can_contribute(author)
    !members_only || memberships.include?(:author_id => author)
  end
end