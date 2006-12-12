require File.dirname(__FILE__) + '/../test_helper'

class HaikuFavoriteTest < Test::Unit::TestCase
  fixtures :users, :haikus
  
  def test_add_haiku_favorite
    haiku = haikus(:hello)
    joe = users(:user_joe)        
   
    haiku.haiku_favorites.create(:user_id => joe.id)
    haiku.save!
    
    assert_equal 1, haiku.haiku_favorites(:refresh).size
    assert_equal 1, haiku.haiku_favorites_count(:refresh)
    
    assert_equal 1, haiku.happy_users(:refresh).size
    
    #assert_equal 1, tag.haiku_favorites_count(:refresh)
    #assert_equal 1, tag.favorites(:refresh).size
  end
end