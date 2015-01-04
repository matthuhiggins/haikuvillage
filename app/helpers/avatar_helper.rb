module AvatarHelper
  SIZE_TO_PIXELS = {
    'small'   => 16,
    'medium'  => 32,
    'large'   => 64
  }

  def small_avatar_image(author)
    avatar_image(author, 'small')
  end

  def medium_avatar_image(author)
    avatar_image(author, 'medium')
  end

  def large_avatar_image(author)
    avatar_image(author, 'large')
  end

  def avatar_image(author, size)
    image_url = author.fb_uid ? facebook_image_url(author.fb_uid) : gravatar_image_url(author.email, size)
    image_tag(image_url, width: SIZE_TO_PIXELS[size])
  end

  def facebook_image_url(fb_uid)
    "http://graph.facebook.com/#{fb_uid}/picture"
  end

  def gravatar_image_url(email, size)
    default_path = image_path("default_avatars/#{size}.png")
    default_url = "http://www.haikuvillage.com/#{default_path}"
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{SIZE_TO_PIXELS[size]}&d=#{CGI.escape(default_url)}"
  end
end
