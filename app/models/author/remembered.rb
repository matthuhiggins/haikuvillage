module Author::Remembered
  def remember_me!
    self.remember_token = ActiveSupport::SecureRandom.base64(32)
    save(false)
  end
  
  def forget_me!
    self.remember_token = nil
    save(false)
  end
end