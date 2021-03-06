class FriendsController < ApplicationController
  login_filter

  def index
    @following = current_author.following.recently_updated
  end

  def update
    @author = Author.find_by_username!(params[:id])
    current_author.friends << @author
    Mailer.new_friend(@author.email, current_author).delive
  end
  
  def destroy
    @author = Author.find_by_username!(params[:id])
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