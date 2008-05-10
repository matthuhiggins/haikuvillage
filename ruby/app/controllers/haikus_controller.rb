class HaikusController < ApplicationController
  login_filter :only => [:new, :create]
  
  def create
    Haiku.create!(:text => params[:haiku][:text], :user => current_user)
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
    render :template => 'templates/haiku'
  end
  
  def destroy
    haiku = Haiku.find(params[:id])
    raise UnauthorizedDestroyRequest unless haiku.user == current_user
    haiku.destroy
    head :ok
  end
  
  def popular
    @title = "Popular haikus"
    list_haikus(Haiku.popular)
  end
end