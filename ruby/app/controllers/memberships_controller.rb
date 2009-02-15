class MembershipsController < ApplicationController
  def index
    @authors = current_group.membershipss
  end

  def create
    current_group.create_membership(:author_id => params[:id])
  end
  
  def update
    current_group
  end
  
  def destroy
    current_group.memberships.destroy(:author_id => params[:id])
  end
  
  private
    def current_group
      @current_group ||= Group.find(param[:group_id])
    end
end