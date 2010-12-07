module Author::Friendly
  extend ActiveSupport::Concern

  included do
    # The authors this author is following
    has_many :friendships
    has_many :following, through: :friendships, :class_name => 'Author', :source => :friend

    has_many :reverse_friendships, :foreign_key => :friend_id, :class_name => 'Friendship'
    has_many :followers, through: :reverse_friendships, :class_name => 'Author'
    
    has_many :friends, :through => :friendships, :class_name => 'Author', :source => :friend, :conditions => {'friendships.mutual' => true}
  end
  
  def mutual?(other_author)
    friends.include?(other_author)
  end

  def feed
    Haiku.recent.where(author_id: [self.id] + following_ids)
  end
end