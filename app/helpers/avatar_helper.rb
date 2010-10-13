module AvatarHelper
  def small_avatar_url(author)
    if fb.connected?
      facebook_image(fb.uid, size: '16x16')
    else
      author.gravatar_url size: 16, default: "http://www.haikuvillage.com/images/default_avatars/small.png"
    end
  end
  
  def medium_avatar_url(author)
    if fb.connected?
      facebook_image(fb.uid, size: '32x32')
    else
      author.gravatar_url size: 32, default: "http://www.haikuvillage.com/images/default_avatars/medium.png"
    end
  end
  
  def large_avatar_url(author)
    if fb.connected?
      facebook_image(fb.uid, size: '64x64')
    else
      author.gravatar_url size: 64, default: "http://www.haikuvillage.com/images/default_avatars/large.png"
    end
  end

  def facebook_image(fb_uid, options)
    image_tag "http://graph.facebook.com/#{fb_uid}/picture"#, options
  end
end