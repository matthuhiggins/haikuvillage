class Group < ActiveRecord::Base
  has_many :haikus
  has_many :memberships
  has_many :authors, :through => :memberships

  validates_presence_of :name

  def can_contribute(author)
    !members_only || memberships.include?(:author_id => author)
  end
end