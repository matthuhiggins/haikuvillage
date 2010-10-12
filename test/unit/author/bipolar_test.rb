require 'test_helper'

class Author::BipolarTest < ActiveSupport::TestCase
  test 'migrate' do
    target = Factory :author
    source = Factory :author
    haiku = Factory :haiku, author: source
    message = Factory :message, author: source, recipient: source
    favorite = Factory :favorite, author: source
    friendship = Factory :friendship, author: source
    reverse_friendship = Factory :friendship, friend: source

    Author.migrate(target, source)

    assert_raise(ActiveRecord::RecordNotFound) { source.reload }
    assert_equal [haiku], target.haikus
    assert_equal [message], target.messages
    assert_equal [favorite], target.favorites
    assert_equal [friendship], target.friendships
    assert_equal [reverse_friendship], target.reverse_friendships
  end

end