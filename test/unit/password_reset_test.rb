require 'test_helper'

class PasswordResetTest < ActiveSupport::TestCase
  def test_author_assigned
    author = Factory :author

    password_reset = PasswordReset.new(:login => author.username)
    assert_equal author, password_reset.author
  end
  
  def test_token_generated
    password_reset = Factory :password_reset
    assert_not_nil password_reset.token
  end

  def test_email_sent
    assert_emails 1 do
      Factory :password_reset
    end
  end
end
