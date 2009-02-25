class Groups::ManageController < ApplicationController
  before_filter :check_admin
  
  def update_logo
    if current_group.update_attributes(params[:group])
      flash[:notice] = 'Logo saved'
    end
    redirect_to :action => 'index'
  end
  
  def admins
    @admins = current_group.memberships.admins
  end
  
  def applications
    @applications = current_group.memberships.applications
  end
  
  def invitations
    @invitations = current_group.memberships.invitations
    if request.delete?
      
    elsif request.post?
      
    end
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