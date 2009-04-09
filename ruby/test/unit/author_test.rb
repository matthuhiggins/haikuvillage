require File.dirname(__FILE__) + '/../test_helper'

class AuthorTest < ActiveSupport::TestCase
  def test_find_by_login_with_username
    assert_equal authors(:billy), Author.find_by_login(authors(:billy).username)
  end

  def test_find_by_login_with_email
    assert_equal authors(:billy), Author.find_by_login(authors(:billy).email)
  end

  def test_find_by_login!
    assert_raises ActiveRecord::RecordNotFound do
      Author.find_by_login!('nouser')
    end
  end
  
  def test_class_authentication
    assert_equal authors(:billy), Author.authenticate(authors(:billy).username, 'billy')
  end
  
  def test_instance_authentication
    assert_equal authors(:billy), authors(:billy).authenticate('billy')
    assert_nil authors(:billy).authenticate('incorrect')
  end
end