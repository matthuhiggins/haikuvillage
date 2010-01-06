module AvatarHelper
  def small_avatar_url(author)
    author.gravatar_url :size => 16, :default => "http://www.haikuvillage.com/images/default_avatars/small.png"
  end
  
  def medium_avatar_url(author)
    author.gravatar_url :size => 32, :default => "http://www.haikuvillage.com/images/default_avatars/medium.png"
  end
  
  def large_avatar_url(author)
    author.gravatar_url :size => 64, :default => "http://www.haikuvillage.com/images/default_avatars/large.png"
  end
end