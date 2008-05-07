class UsersController < ApplicationController
  def show
    @haikus = User.find_by_username(params[:id]).haikus(:limit => 6)
    @title = "Haikus by #{params[:id]}"
    render :template => "templates/listing"
  end
  
  def favorites
    @haikus = User.find_by_username(params[:id]).favorites(:limit => 6)
    @title = "Haikus that #{params[:id]} likes"
    render :template => "templates/listing"
  end
end