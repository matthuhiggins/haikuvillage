class GroupsController < ApplicationController
  layout "haikus"
  
  # GET /groups
  # GET /groups.xml
  def index
    @groups = Group.find(:all, :limit => 20)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @groups.to_xml }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @group.to_xml }
    end
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1;edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        #a group always has at least one member
        @group.group_users.create(:user_id => session[:user_id], 
                                    :user_type => "admin")
        
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to group_url(@group) }
        format.xml  { head :created, :location => group_url(@group) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors.to_xml }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to group_url(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors.to_xml }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.xml  { head :ok }
    end
  end
  
  #user should only be able to hit this if they're signed-in
  def join
    @group = Group.find(params[:id])
    User.find(session[:user_id]).join(@group)
    redirect_to group_url(@group)
  end
  
  def leave
    @group = Group.find(params[:id])
    User.find(session[:user_id]).leave(@group)
    redirect_to groups_url
  end
  
  private
  
  def get_sub_menu
    @sub_menu = [
      ["Groups", "index"],
      ["Create Group", "new"],
      ["Search Groups", {:action => "groups", :controller => "search"}]
    ]
  end
end