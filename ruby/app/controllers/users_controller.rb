class UsersController < ApplicationController
  def show
    list_haikus(User.find_by_username(params[:id]), :haikus, :title => "Haikus by #{params[:id]}")
  end
  
  def favorites
    list_haikus(User.find_by_username(params[:id]), :favorites, :title = "Haikus that #{params[:id]} likes")
  end
end