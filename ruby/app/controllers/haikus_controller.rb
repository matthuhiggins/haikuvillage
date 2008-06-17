class HaikusController < ApplicationController
  class HaikusControllerError < StandardError
  end
  
  # Raised when destroy is performed on a haiku not owned by current_author
  class UnauthorizedDestroyRequest < HaikusControllerError
  end
  
  # Raised when update is performed on a haiku not owned by current_author  
  class UnauthorizedUpdateRequest < HaikusControllerError
  end
  
  login_filter :only => [:new, :destroy, :update]
  
  def create
    if current_author
      @haiku = Haiku.create(:text => params[:haiku][:text], :subject_name => params[:haiku][:subject_name], :author => current_author)
      flash[:new_haiku_id] = @haiku.id
      redirect_to :controller => 'journal'
    else
      logger.debug('WE ARE HERE')
      logger.debug(register_url)
      flash[:new_haiku_text] = params[:haiku][:text]
      redirect_to register_url
    end
  end
  
  def index
    list_haikus(Haiku)
  end
  
  def show
    @haiku = Haiku.find(params[:id])
    @haikus_by_same_author = @haiku.author.haikus.all(:limit => 4, :order => "favorited_count_total desc", :conditions => ['id <> ?', @haiku])
    @favorite_authors = @haiku.happy_authors
    Haiku.update_counters(params[:id], :view_count_week => 1, :view_count_total => 1)
  end
  
  def destroy
    haiku = Haiku.find(params[:id])
    raise UnauthorizedDestroyRequest unless haiku.author == current_author
    haiku.destroy
    
    respond_to do |f|
      f.html { redirect_to (haiku_url(haiku) == referring_uri ? {:controller => 'journal'} : referring_uri) }
      f.js   { head :ok }
    end
  end
  
  def update
    haiku = Haiku.find(params[:id])
    raise UnauthorizedUpdateRequest unless haiku.author == current_author
    haiku.subject_name = params[:haiku][:subject_name]
  end
end