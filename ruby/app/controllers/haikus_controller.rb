class HaikusController < ApplicationController
  login_filter :only => [:new, :destroy, :update, :email, :deliver]
  
  def create
    if current_author
      @haiku = current_author.haikus.create(params[:haiku])
      flash[:new_haiku_id] = @haiku.id
      flash[:notice] = "Your haiku has been created"
      redirect_to(:back)
    else
      session[:new_haiku] = params[:haiku]
      session[:original_login_referrer] = request.referrer
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
  rescue ActiveRecord::RecordNotFound
    redirect_to(root_url)
  end
  
  def destroy
    haiku = current_author.haikus.destroy(params[:id])
    flash[:notice] = "Your haiku was deleted"
    respond_to do |f|
      f.html { redirect_to(haiku_url(haiku) == request.referrer ? {:controller => 'journal'} : request.referrer) }
      f.js   { head :ok }
    end
  end
  
  def email
    @haiku = Haiku.find(params[:id])
  end
  
  def deliver
    haiku = Haiku.find(params[:id])
    Mailer.deliver_haiku(haiku, params[:email], current_author)
    flash[:notice] = "The haiku has been sent"
    redirect_to params[:referrer]
  end
end