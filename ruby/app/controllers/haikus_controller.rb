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
      redirect_to(register_path)
    end
  end

  def index
    @haikus = Haiku.recent.paginate(:page => params[:page], :per_page => 10)
  end
  
  def search
    @haikus = params[:q] &&
      Haiku.search(params[:q], :page => params[:page], :per_page => 10)
  end
  
  def show
    @single_haiku = Haiku.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to(root_path)
  end
  
  def destroy
    haiku = current_author.haikus.destroy(params[:id])
    flash[:notice] = "Your haiku was deleted"
    respond_to do |f|
      f.html { redirect_to(haiku_path(haiku) == request.referrer ? {:controller => 'journal'} : request.referrer) }
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