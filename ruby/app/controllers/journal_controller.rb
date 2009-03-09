class JournalController < ApplicationController
  login_filter

  def index
    @haikus = current_author.haikus.recent.paginate({
      :page      => params[:page],
      :per_page  => 10,
      :total_entries => current_author.haikus_count_total
    })
  end

  def subjects
    if params[:id]
      @haikus = current_author.haikus.recent.find_all_by_subject_name(params[:id]).paginate(
        :page      => params[:page],
        :per_page  => 10
      )
      render "haikus_by_subject"
    else
      @subjects = current_author.subjects
    end
  end
  
  def cancel_application
    application = current_author.memberships.applications.destroy(params[:id])
    flash[:notice] = "Cancelled application for #{application.group.name}"
    redirect_to :controller => "/groups"
  end
  
  def accept_invitation
    invitation = current_author.memberships.invitations.find(params[:id])
    current_author.accept_invitation(invitation)
    flash[:notice] = "Accepted invitation for #{invitation.group.name}"
    redirect_to :controller => "/groups"
  end
  
  def reject_invitation
    invitation = current_author.memberships.invitations.destroy(params[:id])
    flash[:notice] = "Rejected invitation for #{invitation.group.name}"
    redirect_to :controller => "/groups"
  end
  
  def leave_group
    membership = current_author.memberships.members.destroy(params[:id])
    flash[:notice] = "Left group #{membership.group.name}"
    redirect_to :controller => "/groups"
  end
end