class AdminController < ApplicationController
  layout "admin"
  
  before_filter :authorize
  
  def index
    @all_users = User.find(:all)
  end
  
  def delete_user
    id = params[:id]
    if id && user = User.find(id)
      begin
        user.destroy
        flash[:notice] = "User #{user.username} deleted"
      rescue Exception => e
        flash[:notice] = e.message
      end
    end
    redirect_to(:action => :index)
  end
end
