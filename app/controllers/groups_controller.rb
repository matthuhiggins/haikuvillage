class GroupsController < ApplicationController
  login_filter :only => [:index, :create, :new, :edit, :update]

  def index
    memberships = current_author.memberships
    @administrates = memberships.admins.all(:include => :group)
    @memberships = memberships.members.all(:include => :group)
    @invitations = memberships.invitations.all(:include => :group)
    @applications = memberships.applications.all(:include => :group)
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
    @haikus = current_group.haikus.recent.all(:limit => 4)
  end
  
  def haikus
    respond_to do |f|
      f.html do
        @haikus = current_group.haikus.recent.paginate(
          :page           => params[:page],
          :per_page       => 20,
          :total_entries  => current_group.haikus_count
        )
      end
      f.atom { render_atom(current_group.haikus.recent.all(:limit => 10)) }
    end
  end
  
  def update
    if current_group.update_attributes(params[:group])
      flash[:notice] = "Group changes saved"
      redirect_to :controller => "/groups/manage", :group_id => current_group
    else
      render 'edit'
    end
  end
  
  def search
    @groups = Group.search(params[:q]).paginate :page => params[:page], :per_page => 10
  end
  
  private
    def current_group
      @current_group ||= Group.find(params[:id])
    end
    helper_method :current_group
end