module AvatarHelper
  def small_avatar_image(author)
    if author.fb_uid
      facebook_image author.fb_uid, size: '16x16'
    else
      gravatar_image author, size: 16, default: 'http://www.haikuvillage.com/images/default_avatars/small.png'
    end
  end
  
  def medium_avatar_image(author)
    if author.fb_uid
      facebook_image author.fb_uid, size: '32x32'
    else
      gravatar_image author, size: 32, default: 'http://www.haikuvillage.com/images/default_avatars/medium.png'
    end
  end
  
  def large_avatar_image(author)
    if author.fb_uid
      facebook_image author.fb_uid, size: '64x64'
    else
      gravatar_image author, size: 64, default: 'http://www.haikuvillage.com/images/default_avatars/large.png'
    end
  end

  def facebook_image(fb_uid, options)
    image_tag("http://graph.facebook.com/#{fb_uid}/picture", options)
  end

  def gravatar_image(author, options)
    image_tag(author.gravatar_url options)
  end
  
end