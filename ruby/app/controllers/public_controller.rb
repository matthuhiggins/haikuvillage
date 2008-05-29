class PublicController < ApplicationController    
  def index
    input_haiku(Haiku.recent, :left_title => 'Welcome to HaikuVillage', :right_title => 'Recent haikus')
  end
end