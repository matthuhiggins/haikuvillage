class Friendship < ActiveRecord::Base
  belongs_to :author
  belongs_to :friend, :class_name => "Author"
  
  def reverse_friendship
    Friendship.find(:conditions => reverse_friendship_attributes)
  end

  def reverse_friendship_attributes
    {:author_id => friend_id, :friend_id => author_id}
  end
end
