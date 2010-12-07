module AvatarHelper
  def small_avatar_image(author)
    avatar_image(author, 16, 'small')
  end
  
  def medium_avatar_image(author)
    avatar_image(author, 32, 'medium')
  end
  
  def large_avatar_image(author)
    avatar_image(author, 64, 'large')
  end

  def avatar_image(author, size, default)
    if author.fb_uid
      facebook_image author.fb_uid, width: size
    else
      gravatar_image author, size: size, default: "http://haikuvillage.com/images/default_avatars/#{default}.png"
    end
  end

  def facebook_image(fb_uid, options)
    image_tag("http://graph.facebook.com/#{fb_uid}/picture", options)
  end

  def gravatar_image(author, options)
    image_tag(author.gravatar_url options)
  end
  
end