module Friendly
  def self.included(author)
    author.has_many :friendships, :after_add => :create_reverse_friendship, :after_remove => :destroy_reverse_friendship
    author.has_many :friends, :through => :friendships, :class_name => "Author"
  end

  def create_reverse_friendship(friendship)
    Friendship.create(friendship.reverse_friendship_attributes)
  end

  def destroy_reverse_friendship(friendship)
    Friendship.destroy(friendship.reverse_friendship_attributes)
  end
end