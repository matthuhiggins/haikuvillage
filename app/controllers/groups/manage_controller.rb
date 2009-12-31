class Groups::ManageController < ApplicationController
  before_filter :check_admin
  
  def memberships
    memberships = current_group.memberships
    @admins = memberships.admins
    @members = memberships.members
    @invitations = memberships.invitations
    @applications = memberships.applications
    @friends = current_author.outsiders(current_group)
  end

  def cancel
    membership = current_group.memberships.destroy(params[:id])
    flash[:notice] = "Cancelled invitation for #{membership.author.username}"
    redirect_to :action => 'memberships'
  end
  
  def reject
    membership = current_group.memberships.destroy(params[:id])
    flash[:notice] = "Rejected application by #{membership.author.username}"
    redirect_to :action => 'memberships'
  end

  def accept
    membership = current_group.memberships.find(params[:id])
    current_group.accept_application(membership)
    flash[:notice] = "Accepted application from #{membership.author.username}"
    redirect_to :action => 'memberships'
  end

  def admin
    membership = current_group.memberships.find(params[:id])
    if request.post?
      membership.update_attribute(:standing, Membership::ADMIN)
      flash[:notice] = "Made #{membership.author.username} an admin"
    elsif request.delete?
      membership.update_attribute(:standing, Membership::MEMBER)
      flash[:notice] = "Removed #{membership.author.username} from admins"
    end
    redirect_to :action => 'memberships'
  end
  
  def remove
    membership = current_group.memberships.destroy(params[:id])
    flash[:notice] = "Removed #{membership.author.username}"
    redirect_to :action => 'memberships'
  end

  def invitations
    @invitations = current_group.memberships.invitations
    if request.delete?
      invitation = current_group.memberships.invitations.find(params[:id])
      flash[:notice] = "You rejected the group invitation"
      redirect_to :todo
    elsif request.post?
      invitation = current_group.memberships.invitations.find(params[:id])
      flash[:notice] = "You rejected the group invitation"
      redirect_to :todo
    end
  end
  
  def invite_members
    (params[:invitations] || []).each do |invitation_id|
      current_group.invite_author(current_author.friends.find(invitation_id))
    end
    flash[:notice] = "Your selected friends were asked to join the group"
    redirect_to :action => 'memberships'
  end
  
  private
    def check_admin
      unless current_author.try(:administrator?, current_group)
        flash[:notice] = "You cannot administer this group"
        redirect_to group_path(current_group)
      end
    end
    
    def current_group
      @current_group ||= Group.find(params[:group_id])
    end
    helper_method :current_group
end