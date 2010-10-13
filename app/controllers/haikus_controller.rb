class HaikusController < ApplicationController
  login_filter :only => [:new, :destroy, :update, :email, :deliver]
  
  def create
    if current_author
      @haiku = current_author.haikus.create(params[:haiku])
      redirect_and_flash(@haiku)
    else
      redirect_with_login_context
    end
  end

  def index
    respond_to do |f|
      f.html { @haikus = Haiku.recent.paginate(:page => params[:page], :per_page => 10) }
      f.atom { render_atom(Haiku.recent.all(:limit => 10)) }
    end
  end
  
  def search
    if params[:q].present?
      @haikus = Haiku.search(params[:q]).paginate :page => params[:page], :per_page => 10
    end
  end
  
  def show
    @single_haiku = Haiku.find_by_param(params[:id])
  end
  
  def destroy
    haiku = current_author.haikus.find(params[:id])
    haiku.destroy
    flash[:notice] = "Your haiku was deleted"
    respond_to do |f|
      f.html { redirect_to(haiku_path(haiku) == request.referrer ? {:controller => 'journal'} : request.referrer) }
      f.js   { head :ok }
    end
  end
  
  private
    def redirect_and_flash(haiku)
      if haiku.conversing_with
        flash[:notice] = "Your haiku started a conversation."
        redirect_to(haiku.conversation)
      else
        flash[:notice] = "Your haiku has been created"
        redirect_to(:back)
      end
    end
end