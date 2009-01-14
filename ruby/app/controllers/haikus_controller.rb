class HaikusController < ApplicationController
  login_filter :only => [:new, :destroy, :update, :email, :deliver_haiku]
  
  def create
    if current_author
      @haiku = current_author.haikus.create(params[:haiku])
      redirect_to(:back)
    else
      session[:new_haiku] = params[:haiku]
      redirect_to(register_url)
    end
  end

  def index
    @haikus = Haiku.recent.paginate(:page => params[:page], :per_page => 10)
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
      f.html { redirect_to(haiku_url(haiku) == request.referrer ? {:controller => 'journal'} : request.referrer) }
      f.js   { head :ok }
    end
  end
  
  def email
    @haiku = Haiku.find(params[:id])
        HaikuMailer.deliver_haiku(@haiku, current_author)
  end
  
  def deliver_haiku
    haiku = Haiku.find(params[:id])
    HaikuMailer.deliver_haiku(haiku, @email)
    redirect_to(haiku_url(haiku) == request.referrer ? {:controller => 'journal'} : request.referrer)
  end
end