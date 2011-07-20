module Author::Remembered
  def remember_me!
    self.remember_token = ActiveSupport::SecureRandom.base64(32)
    save(validation: false)
  end
  
  def forget_me!
    self.remember_token = nil
    save(validation: false)
  end
end