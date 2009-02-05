class Authors::FriendsController < ApplicationController
  def index
    @author = Author.find_by_username!(params[:author_id])
    @friends = @author.friends.recently_updated
  end
  
  def create
    @author = Author.find_by_username!(params[:author_id])
    current_author.friends << @author
    Mailer.deliver_new_friend(@author.email, current_author)
  end
  
  def destroy
    @author = Author.find_by_username!(params[:author_id])
    Friendship.destroy_all(:author_id => current_author, :friend_id => @author)
    respond_to do |f|
      f.js
      f.html do
        flash[:notice] = "#{@author.username} removed from friends"
        redirect_to :back
      end
    end
  end
end