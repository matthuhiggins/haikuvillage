module Author::Social
  def self.included(author)
    author.class_eval do 
      author.has_many :memberships
      author.has_many :groups, :through => :memberships
    end
  end

  def contributor?(group)
    memberships.contributors.exists?(:group_id => group)
  end
  
  def invited?(group)
    memberships.invitations.exists?(:group_id => group)
  end
  
  def administrator?(group)
    memberships.admins.exists?(:group_id => group)
  end
  
  def outsiders(group)
    friends.all(
      :order => :username,
      :conditions => ['authors.id not in (select author_id from memberships where group_id = ?)', group]
    )
  end
end