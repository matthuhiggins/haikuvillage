module Author::Social
  def self.included(author)
    author.class_eval do 
      author.has_many :memberships
      author.has_many :groups, :through => :memberships
    end
  end

  def can_contribute?(group)
    !group.members_only || memberships.contributors.exists?(:group_id => group)
  end
  
  def can_administer?(group)
    memberships.admins.exists?(:group_id => group)
  end
end