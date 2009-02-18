class MembershipsController < ApplicationController
  def index
    @group = current_group
    @authors = @group.memberships
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
      @current_group ||= Group.find(params[:group_id])
    end
end