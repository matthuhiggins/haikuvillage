module Friendly
  def self.included(author)
    author.has_many :friendships, :after_add => :create_mutual_friendship, :after_remove => :destroy_mutual_friendship
    author.has_many :friends, :through => :friendships, :class_name => "Author"
  end

  def create_mutual_friendship(friendship)
    if Friendship.exists?(friendship.reverse_friendship_attributes)
      friendship.reverse_friendship.update(:mutual, true)
    end
  end

  def destroy_mutual_friendship(friendship)
    if Friendship.exists?(friendship.reverse_friendship_attributes)
      friendship.reverse_friendship.update(:mutual, false)
    end
  end
end