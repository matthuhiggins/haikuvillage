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
    @haikus = @group.haikus.all(:limit => 10)
  end
  
  def haikus
    @group = Group.find(params[:id])
    @haikus = @group.haikus.paginate(:page => params[:page], :per_page => 10)
  end
  
  def update
    
  end
end