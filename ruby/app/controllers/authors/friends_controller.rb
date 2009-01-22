class Authors::FriendsController < ApplicationController
  def index
    @friends = Author.find_by_username(params[:author_id]).friends
  end
  
  def create
    current_author.friends << Author.find_by_username(params[:author_id])
    head :ok
  end
end