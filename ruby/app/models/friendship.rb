class FriendShip < ActiveRecord::Base
  belongs_to :author
  belongs_to :friend, :class_name => "Author"
  
  def reverse_friendship_attributes
    {:author_id => friend_id, :friend_id => author_id}
  end
end
