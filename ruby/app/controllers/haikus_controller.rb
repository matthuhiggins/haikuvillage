class HaikusController < ApplicationController
  login_filter :only => [:new, :destroy, :update]
  
  def create
    if current_author
      create_haiku_and_redirect
    else
      session[:new_haiku] = params[:haiku]
      redirect_to register_url
    end
  end
  
  def index
    @haikus = Haiku.recent.paginate(:page => params[:page], :per_page  => 10)
  end
  
  def search
    @haikus = Haiku.search(params[:q],
      :page      => params[:page],
      :per_page  => 10)
  end
  
  def show
    @single_haiku = Haiku.find(params[:id])
    Haiku.update_counters(params[:id], :view_count_week => 1, :view_count_total => 1)
  end
  
  def destroy
    haiku = current_author.haikus.destroy(params[:id])
    
    respond_to do |f|
      f.html { redirect_to(haiku_url(haiku) == referring_uri ? {:controller => 'journal'} : referring_uri) }
      f.js   { head :ok }
    end
  end
end