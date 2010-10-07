require 'test_helper'

class Author::UniqueUsernameTest < ActiveSupport::TestCase
  test 'find_unique_username' do
    Factory :author, username: 'foo'
    Factory :author, username: 'foo1'

    assert_equal 'foo2', Author.find_unique_username('f.oo@bar.net')
  end
end