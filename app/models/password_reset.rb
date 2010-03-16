class PasswordReset < ActiveRecord::Base
  belongs_to :author
  before_create :generate_token
  after_create :send_email

  def login=(login)
    self.author = Author.find_by_login!(login)
  end

  private
    def generate_token
      self.token = ActiveSupport::SecureRandom.hex(16)
    end
    
    def send_email
      Mailer.deliver_password_reset(self)
    end
end
