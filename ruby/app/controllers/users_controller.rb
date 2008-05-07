class UsersController < ApplicationController
  def show
    render :text => User.find_by_username(params[:id]).haikus(:limit => 6)
  end
  
  def favorites
    render :text => User.find_by_username(params[:id]).favorites(:limit => 6)
  end
end