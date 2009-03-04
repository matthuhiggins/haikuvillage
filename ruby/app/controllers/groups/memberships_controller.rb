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
  
  def update
    current_group
  end
  
  def destroy
    current_group.memberships.destroy(:author_id => params[:id])
  end

  def apply
    raise StandardError unless current_group.invite_only
    return unless request.post?
    current_group.apply_for_membership(current_author)
    flash[:notice] = "We sent your request to the group admins"
    redirect_to group_url(current_group)
  end
  
  def accept
    return unless request.post?
    current_group.accept_invitation(current_author)
    flash[:notice] = "You are now a member of #{current_group.name}"
    redirect_to group_url(current_group)
  end
  
  def join
    raise StandardError if current_group.invite_only
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