require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  def test_find_by_login_with_username
    author = Factory :author
    assert_equal author, Author.find_by_login(author.username)
  end

  def test_find_by_login_with_email
    author = Factory :author
    assert_equal author, Author.find_by_login(author.email)
  end

  def test_find_by_login!
    assert_raises ActiveRecord::RecordNotFound do
      Author.find_by_login!('nouser')
    end
  end
  
  def test_class_authentication
    author = Factory :author, :password => 'foo'
    assert_equal author, Author.authenticate(author.username, 'foo')
    assert_equal author, Author.authenticate(author.email, 'foo')
    assert_nil Author.authenticate(author.username, 'bar')
    assert_nil Author.authenticate('noway', 'foo')
  end
  
  def test_instance_authentication
    author = Factory :author, :password => 'foo'
    assert author.authenticate('foo')
    assert !author.authenticate('bar')
  end
  
  def test_username_downcased
    author = Factory(:author, :username => 'FOO')
    assert_equal 'foo', author.username
    
    author.update_attributes(:username => 'BAR')
    assert_equal 'bar', author.username
  end
end