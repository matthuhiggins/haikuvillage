require 'test_helper'

class Author::BipolarTest < ActiveSupport::TestCase
  test 'migrate' do
    existing_author = Factory :author
    facebook_author = Factory :author, fb_uid: 42
    haiku = Factory :haiku, author: facebook_author
    message = Factory :message, author: facebook_author, recipient: facebook_author
    favorite = Factory :favorite, author: facebook_author
    friendship = Factory :friendship, author: facebook_author
    reverse_friendship = Factory :friendship, friend: facebook_author

    Author.migrate(existing_author, facebook_author)

    assert_raise(ActiveRecord::RecordNotFound) { facebook_author.reload }
    assert_equal [haiku], existing_author.haikus
    assert_equal [message], existing_author.messages
    assert_equal [favorite], existing_author.favorites
    assert_equal [friendship], existing_author.friendships
    assert_equal [reverse_friendship], existing_author.reverse_friendships
    assert_equal 42, existing_author.fb_uid
  end

  test 'find_unique_username' do
    Factory :author, username: 'foo'
    Factory :author, username: 'foo1'

    assert_equal 'foo2', Author.find_unique_username('f.oo@bar.net')
  end
end