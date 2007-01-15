require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def test_user
    joe = users(:user_joe)
    assert(joe.username == "joe")
  end
end
