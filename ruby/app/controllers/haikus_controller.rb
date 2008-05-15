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
    @title = "Recent"
    list_haikus(Haiku.recent)
  end
  
  def show
    @haiku = Haiku.find(params[:id])
    @users = @haiku.happy_users.all(:limit => 6)
    @haikus_by_same_user = @haiku.user.haikus.all(:limit => 3, :order => "favorited_count_total desc", :conditions => ['id <> ?', @haiku])

    Haiku.update_counters(params[:id], :view_count_week => 1, :view_count_month => 1, :view_count_total => 1)
  end
  
  def destroy
    haiku = Haiku.find(params[:id])
    raise UnauthorizedDestroyRequest unless haiku.user == current_user
    haiku.destroy
    
    respond_to do |f|
      f.html { redirect_to referring_uri }
      f.js   { head :ok }
    end
  end
  
  def top_favorites
    @title = "Top Favorites"
    list_haikus(Haiku.top_favorites)
  end
  
  def most_viewed
    @title = "Most Viewed"
    list_haikus(Haiku.most_viewed)
  end
end