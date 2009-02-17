class GroupsController < ApplicationController
  def index
    @groups = Group.paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @group = Group.new
  end
  
  def create
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = "Welcome to your new group"
      redirect_to(@group)
    else
      render 'new'
    end
  end
  
  def show
    @group = Group.find(params[:id])
  end
  
  def update
    
  end
end