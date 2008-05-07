class WelcomeController < ApplicationController    
  def index
    @haikus = Haiku.recent
    @title = "Welcome to HaikuVillage"
    render :template => "templates/input"
  end
end