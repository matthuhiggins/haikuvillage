class HaikusController < ApplicationController
  login_filter :only => [:new, :create]
  
  def create
    @haiku = Haiku.create(:text => params[:haiku][:text], :user => current_user)
    if @haiku.errors.empty?
      flash[:new_haiku_id] = @haiku.id
    else
      flash[:notice] = "You must enter a valid haiku"
    end
    redirect_to create_url
  end
  
  def new
    @title = "Create your haiku"
    input_haiku(current_user.haikus.recent)
  end
  
  def index
    @title = "Recent Haikus"
    list_haikus(Haiku.recent)
  end
  
  def show
    @haiku = Haiku.find(params[:id])
    @users = @haiku.happy_users.all(:limit => 6)
    @user_haikus = @haiku.user.haikus.all(:limit => 3, :order => "favorited_count desc")
    render :template => 'templates/haiku'
  end
  
  def destroy
    haiku = Haiku.find(params[:id])
    raise UnauthorizedDestroyRequest unless haiku.user == current_user
    haiku.destroy
    
    logger.debug(referring_uri)
    respond_to do |f|
      f.html { redirect_to referring_uri }
      f.js   { head :ok }
    end
  end
  
  def popular
    @title = "Popular haikus"
    list_haikus(Haiku.popular)
  end
end