class PublicController < ApplicationController    
  def index
    @title = "Welcome to HaikuVillage"
    input_haiku(Haiku.recent)
  end
end