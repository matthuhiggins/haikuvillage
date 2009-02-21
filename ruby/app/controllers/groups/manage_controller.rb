class Groups::ManageController < ApplicationController
  before_filter :check_admin

  def index
    render :text => params.inspect
  end
  
  def update_avatar
    if current_group.update_attributes(params[:group])
      flash[:notice] = 'Avatar saved'
    end
    redirect_to :action => 'avatar'
  end
  
  private
    def check_admin
      unless current_author.try(:can_administer?, current_group)
        flash[:notice] = "You cannot administer this group"
        redirect_to group_path(current_group)
      end
    end
    
    def current_group
      @current_group ||= Group.find(params[:group_id])
    end
    helper_method :current_group
end