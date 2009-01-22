class Friendship < ActiveRecord::Base
  belongs_to :author
  belongs_to :friend, :class_name => "Author"
  
  before_create :set_mutual
  
  private
    def set_mutual
      self.mutual = !reverse_friendship.nil?
      reverse_friendship.update(:mutual, true) if self.mutual
    end
    
    def reverse_friendship
      Friendship.first(:conditions => reverse_friendship_attributes)
    end

    def reverse_friendship_attributes
      {:author_id => friend_id, :friend_id => author_id}
    end
end
