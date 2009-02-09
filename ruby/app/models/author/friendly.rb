module Friendly
  class << self
    def included(author)
      # The authors this author is following
      author.has_many :following, :class_name => "Friendship", :after_add => :create_mutual_friendship, :after_remove => :destroy_mutual_friendship
      author.has_many :friends, :through => :following, :class_name => "Author", :source => :friend
      author.has_many :mutual_friends, :through => :following, :class_name => "Author", :source => :friend, :conditions => {'friendships.mutual' => true}
      author.has_many :mentors, :through => :following, :class_name => "Author", :source => :friend, :conditions => {'friendships.mutual' => false}

      # The authors following this author
      author.has_many :followers, :foreign_key => :friend_id, :class_name => "Friendship"
      author.has_many :disciples, :through => :followers, :class_name => "Author", :source => :author, :conditions => {'friendships.mutual' => false}
    end
  end
  
  def mutual?(other_author)
    mutual_friends.include?(other_author)
  end
end