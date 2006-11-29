class UsersController < ApplicationController
  def index
    @haikus = Haiku.get_haikus.map{|haiku| HaikuView.from_haiku(haiku)}
  end
end
