require File.dirname(__FILE__) + '/../test_helper'

class HaikuTest < Test::Unit::TestCase
  fixtures :users, :haikus
  
  def test_user
#    haiku = Haiku.new(:title => "my haiku",
#                      :line1 => "this is my first haiku",
#                      :line2 => "i cannot count to seven",
#                      :line3 => "but i can attempt")
#    haiku.author = users(:user_joe)
#    assert haiku.save
  end
  
  def test_search
    haikus = Haiku.find(:all)
    assert_equal 3, haikus.size
    haikus = Haiku.find(:all, :conditions => ["user_id = ?" , 1])
    assert_equal 2, haikus.size
    haikus = Haiku.find(:all, :conditions => ["user_id = ?" , 2])
    assert_equal 1, haikus.size

    haikus = Tag.find(:first, :conditions => ["name = ?" , "foobar"]).haikus
  end
end