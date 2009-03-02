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
    respnd_to do |f|
      f.html { @haikus = current_group.haikus.recent.all(:limit => 4) }
      f.atom { render_atom(current_group.haikus.recent.all(:limit => 10)) }
    end
  end
  
  def haikus
    @haikus = current_group.haikus.recent.paginate(
      :page           => params[:page],
      :per_page       => 20,
      :total_entries  => current_group.haikus_count
    )
  end
  
  def update
    if current_group.update_attributes(params[:group])
      flash[:notice] = "Group changes saved"
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