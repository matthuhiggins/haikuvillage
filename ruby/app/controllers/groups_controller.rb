class GroupsController < ApplicationController
  def index
    @groups = Group.paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @group = Group.new
  end
  
  def create
    @group = Group.new(params[:group])
    @group.
    if @group.save
      flash[:notice] = "Welcome to your new group"
      redirect_to(@group)
    else
      render 'new'
    end
  end
  
  def show
    @haikus = current_group.haikus.recent(:limit => 6)
  end
  
  def haikus
    @haikus = current_group.haikus.recent.paginate(:page => params[:page], :per_page => 10)
  end
  
  private
    def current_group
      @current_group ||= Group.find(params[:id])
    end
    helper_method :current_group
end