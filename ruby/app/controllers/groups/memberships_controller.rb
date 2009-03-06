class Groups::MembershipsController < ApplicationController
  login_filter :only => [:apply, :accept]

  def index
    memberships = current_group.memberships
    @admins = memberships.admins
    @members = memberships.members
  end

  def create
    current_group.memberships.create(:author_id => params[:id])
  end
  
  def destroy
    current_group.memberships.destroy(:author_id => params[:id])
  end

  def apply
    redirect_to(group_path(current_group)) if current_author.contributor?(current_group)
    return unless request.post?
    current_group.apply_for_membership(current_author)
    flash[:notice] = "We sent your request to the group admins"
    redirect_to group_url(current_group)
  end
  
  def accept
    redirect_to(group_path(current_group)) unless current_author.invited?(current_group)
    return unless request.post?
    current_group.add_member(current_author)
    flash[:notice] = "You are now a member of #{current_group.name}"
    redirect_to group_url(current_group)
  end
  
  def join
    redirect_to(group_path(current_group)) if current_group.invite_only
    return unless request.post?
    current_group.add_member(current_author)
    flash[:notice] = "You are now a member of #{current_group.name}"
    redirect_to group_url(current_group)
  end

  private
    def current_group
      @current_group ||= Group.find(params[:group_id])
    end
    helper_method :current_group
end