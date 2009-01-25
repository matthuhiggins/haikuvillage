class Authors::FriendsController < ApplicationController
  def index
    @author = Author.find_by_username(params[:author_id])
    @friends = @author.friends
  end
  
  def create
    current_author.friends << Author.find_by_username(params[:author_id])
    head :ok
  end
end