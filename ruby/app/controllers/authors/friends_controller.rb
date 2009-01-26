class Authors::FriendsController < ApplicationController
  def index
    @author = Author.find_by_username(params[:author_id])
    @friends = @author.friends
  end
  
  def create
    @author = Author.find_by_username(params[:author_id])
    current_author.friends << @author
  end
  
  def destroy
    @author = Author.find_by_username(params[:author_id])
    Friendship.destroy_all(:author_id => current_author, :friend_id => @author)
  end
end