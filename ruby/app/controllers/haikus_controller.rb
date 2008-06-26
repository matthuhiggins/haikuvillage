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
      @haiku = Haiku.create(params[:haiku].update(:author => current_author))
      flash[:new_haiku_id] = @haiku.id
      redirect_to :controller => 'journal'
    else
      session[:new_haiku] = params[:haiku]
      redirect_to register_url
    end
  end
  
  def index
    @meta_description = "A listing of assorted haikus"
    list_haikus(Haiku)
  end
  
  def show
    @single_haiku = Haiku.find(params[:id])
    @meta_description = @single_haiku.text.gsub(/\r\n|\r|\n/, ' / ')
    Haiku.update_counters(params[:id], :view_count_week => 1, :view_count_total => 1)
  end
  
  def destroy
    haiku = Haiku.find(params[:id])
    raise UnauthorizedDestroyRequest unless haiku.author == current_author
    haiku.destroy
    
    respond_to do |f|
      f.html { redirect_to(haiku_url(haiku) == referring_uri ? {:controller => 'journal'} : referring_uri) }
      f.js   { head :ok }
    end
  end
  
  def update
    haiku = Haiku.find(params[:id])
    raise UnauthorizedUpdateRequest unless haiku.author == current_author
    haiku.subject_name = params[:haiku][:subject_name]
  end
end