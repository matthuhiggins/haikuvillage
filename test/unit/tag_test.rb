require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :users, :haikus, :tags

  def test_add_new
    tag = tags(:winter)
    haiku = haikus(:hello)
    tag.haiku_tags.create(:haiku => haiku)
    tag.save!
    assert_equal 1, tag.haiku_tags_count
  end
  
#  def test_add_existing
#    haiku = haikus(:hello)
#    tag = Tag.add_haiku_tag("winter", haiku)
#    assert_equal 1, tag.haiku_tags_count
#    assert_equal 1, tag.haikus.size
#  end
end