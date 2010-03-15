require 'test_helper'

class PasswordResetTest < ActiveSupport::TestCase
  should_belong_to :author

  def test_author_assigned
    password_reset = PasswordReset.new(:login => authors(:billy).username)
    assert_equal authors(:billy), password_reset.author
  end
  
  def test_token_generated
    password_reset = PasswordReset.new
    password_reset.valid?
    assert_not_nil password_reset.token
  end

  def test_email_sent
    assert_emails(1) { PasswordReset.create(:author => authors(:billy)) }
  end
end
