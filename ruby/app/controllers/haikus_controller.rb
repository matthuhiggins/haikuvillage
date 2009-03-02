class HaikusController < ApplicationController
  login_filter :only => [:new, :destroy, :update, :email, :deliver]
  
  def create
    if current_author
      @haiku = current_author.haikus.create(params[:haiku])
      flash[:new_haiku_id] = @haiku.id
      redirect_and_flash(@haiku)
    else
      redirect_with_login_context do
        session[:new_haiku] = params[:haiku]
      end
    end
  end

  def index
    
    respond_to do |f|
      f.html { @haikus = Haiku.recent.paginate(:page => params[:page], :per_page => 10) }
      f.atom { render_atom(Haiku.recent.all(:limit => 10)) }
    end
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
  
  private
    def redirect_and_flash(haiku)
      if !haiku.conversing_with.nil?
        flash[:notice] = "Your haiku started a conversation."
        redirect_to(haiku.conversation)
      elsif !haiku.conversation.nil?
        flash[:notice] = "Your haiku has been added to the conversation."
        redirect_to(haiku.conversation)
      elsif !haiku.group_id.nil?
        flash[:notice] =
          "Your haiku was has been added to the group. " +
          "<a href=\"#{url_for(contribute_group_path(haiku.group))}\">Contribute another haiku</a>"
        redirect_to(haikus_group_path(haiku.group))
      else
        flash[:notice] = "Your haiku has been created"
        redirect_to(:back)
      end
    end
end