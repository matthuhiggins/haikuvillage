class Groups::ManageController < ApplicationController
  before_filter :check_admin

  def index
  end
  
  def update_logo
    if current_group.update_attributes(params[:group])
      flash[:notice] = 'Logo saved'
    end
    redirect_to :action => 'index'
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