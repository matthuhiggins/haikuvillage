class Friendship < ActiveRecord::Base
  belongs_to :author
  belongs_to :friend, :class_name => "Author"
  
  before_create :set_mutual
  after_destroy :destroy_mutual
  
  private
    def set_mutual
      self.mutual = self.class.exists?(reverse_friendship_attributes)
      self.class.update_all({:mutual => true}, reverse_friendship_attributes)
    end
    
    def destroy_mutual
      self.class.update_all({:mutual => false}, reverse_friendship_attributes)
    end

    def reverse_friendship_attributes
      {:author_id => friend_id, :friend_id => author_id}
    end
end
