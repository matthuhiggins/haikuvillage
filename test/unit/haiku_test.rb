require File.dirname(__FILE__) + '/../test_helper'

class HaikuTest < Test::Unit::TestCase
  fixtures :users, :haikus
  
  def test_user
    haiku = Haiku.new(:title => "my haiku",
                      :line1 => "this is my first haiku",
                      :line2 => "i cannot count to seven",
                      :line3 => "but i can attempt")
    haiku.user = users(:user_joe)
    assert haiku.save
  end
end