class PasswordReset < ActiveRecord::Base
  belongs_to :author

  attr_accessor :password
  validates_presence_of :password, on: :update

  before_create do
    self.token = SecureRandom.hex(16)
  end

  after_create do
    Mailer.password_reset(self).deliver
  end

  before_update if: :password do
    author.update_attributes(password: password)
  end

  def login=(login)
    self.author = Author.find_by_login!(login)
  end

  def to_param
    token
  end
end
