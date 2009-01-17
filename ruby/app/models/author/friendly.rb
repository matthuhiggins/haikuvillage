module Friendly
  has_many :friendships, :after_add => :create_reverse_friendship, :after_remove => :destroy_reverse_friendship
  has_many :friends, :through => :friendships, :class_name => "Author"

  def create_reverse_friendship(friendship)
    Friendship.create(friendship.reverse_friendship_attributes)
  end

  def destroy_reverse_friendship(friendship)
    Friendship.destroy(friendship.reverse_friendship_attributes)
  end
end