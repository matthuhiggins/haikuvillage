class Authors::FriendsController < ApplicationController
  def index
    @author = Author.find_by_username(params[:author_id])
    @friends = @author.friends.recently_updated
  end
  
  def create
    @author = Author.find_by_username(params[:author_id])
    current_author.friends << @author
    HaikuMailer.deliver_new_friend(current_author, @author.email)
  end
  
  def destroy
    @author = Author.find_by_username(params[:author_id])
    Friendship.destroy_all(:author_id => current_author, :friend_id => @author)
  end
end