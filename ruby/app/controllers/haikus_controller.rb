class HaikusController < ApplicationController
  class HaikusControllerError < StandardError
  end
  # Raised when destroy is performed on a haiku not owned by current_author
  class UnauthorizedDestroyRequest < HaikusControllerError
  end
  
  # Raised when update is performed on a haiku not owned by current_author  
  class UnauthorizedUpdateRequest < HaikusControllerError
  end
  
  login_filter :only => [:new, :create]
  
  def create
    @haiku = Haiku.create(:text => params[:haiku][:text], :subject_name => params[:haiku][:subject_name], :author => current_author)
    if @haiku.errors.empty?
      flash[:new_haiku_id] = @haiku.id
    else
      flash[:notice] = "You must enter a valid haiku"
    end
    redirect_to create_url
  end
  
  def new
    input_haiku(current_author.haikus.recent, :left_title => 'Create a haiku', :right_title => 'Your recent haikus')
  end
  
  def index
    list_haikus(Haiku, :recent)
  end
  
  def show
    @haiku = Haiku.find(params[:id])
    @title = "A haiku by #{@haiku.author.username}"
    @haikus_by_same_author = @haiku.author.haikus.all(:limit => 4, :order => "favorited_count_total desc", :conditions => ['id <> ?', @haiku])

    Haiku.update_counters(params[:id], :view_count_week => 1, :view_count_total => 1)
  end
  
  def destroy
    haiku = Haiku.find(params[:id])
    raise UnauthorizedDestroyRequest unless haiku.author == current_author
    haiku.destroy
    
    respond_to do |f|
      f.html { redirect_to referring_uri }
      f.js   { head :ok }
    end
  end
  
  def update
    haiku = Haiku.find(params[:id])
    raise UnauthorizedUpdateRequest unless haiku.author == current_author
    haiku.subject_name = params[:haiku][:subject_name]
  end
  
  def top_favorites
    list_haikus(Haiku, :top_favorites, :title => "Top Favorites (weekly)")
  end
  
  def most_viewed
    list_haikus(Haiku, :most_viewed, :title => "Most Viewed (weekly)")
  end
end