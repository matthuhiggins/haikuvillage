class GroupsController < ApplicationController
  login_filter :only => [:create, :new, :edit, :update]

  def index
    @groups = Group.paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @group = Group.new
  end
  
  def create
    @group = Group.new(params[:group])
    if @group.save
      @group.add_admin(current_author)
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
  
  def update
    if current_group.update_attributes(params[:group])
      flash[:notice] = "Name & description saved"
      redirect_to :controller => "/groups/manage", :group_id => current_group
    else
      render 'edit'
    end
  end
  
  private
    def current_group
      @current_group ||= Group.find(params[:id])
    end
    helper_method :current_group
end