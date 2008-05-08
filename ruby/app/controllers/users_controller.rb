class UsersController < ApplicationController
  def show
    @title = "Haikus by #{params[:id]}"
    list_haikus(User.find_by_username(params[:id]).haikus)
  end
  
  def favorites
    @title = "Haikus that #{params[:id]} likes"
    list_haikus(User.find_by_username(params[:id]).favorites)
  end
end