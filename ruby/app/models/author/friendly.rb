module Friendly
  class << self
    def included(author)
      author.has_many :friendships, :after_add => :create_mutual_friendship, :after_remove => :destroy_mutual_friendship
      author.has_many :disciples, default_friendship_options.update(:conditions => {'friendships.mutual' => false})
      author.has_many :mentors, default_friendship_options.update(:conditions => {'friendships.mutual' => true})
    end
    
    def default_friendship_options
      {:through => :friendships, :class_name => "Author", :source => :friend}
    end
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