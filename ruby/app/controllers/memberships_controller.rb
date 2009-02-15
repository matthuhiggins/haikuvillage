class MembershipsController < ApplicationController
  def index
    
  end

  def create
    Membership.create
  end
  
  def destroy
    Membership.destroy(params[:id])
  end
end