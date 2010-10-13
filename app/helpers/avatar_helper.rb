module AvatarHelper
  def small_avatar_url(author)
    if fb.connected?
    else
      author.gravatar_url :size => 16, :default => "http://www.haikuvillage.com/images/default_avatars/small.png"
    end
  end
  
  def medium_avatar_url(author)
    if fb.connected?
    else
      author.gravatar_url :size => 32, :default => "http://www.haikuvillage.com/images/default_avatars/medium.png"
    end
  end
  
  def large_avatar_url(author)
    if fb.connected?
      
    else
      author.gravatar_url :size => 64, :default => "http://www.haikuvillage.com/images/default_avatars/large.png"
    end
  end
end