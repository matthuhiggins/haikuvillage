require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :users, :haikus, :tags

  def test_add_new_tag
    haiku = haikus(:hello)
    tag = Tag.add_haiku_tag("new tag", haiku)
    
    assert_equal "new tag", tag.name 
    assert_equal 1, tag.haiku_tags_count(:refresh)
    assert_equal 1, tag.haiku_tags(:refresh).size    
  end
  
#  def test_add_existing_tag
#    tag = tags(:winter)
#    haiku = haikus(:hello)
#    assert_equal 0, tag.haiku_tags_count
#    
#    tag = Tag.add_haiku_tag(tag.name, haiku)
#    assert_equal "winter", tag.name 
#    assert_equal 1, tag.haiku_tags_count
#    assert_equal 1, tag.haiku_tags(:refresh).size    
#  end
end