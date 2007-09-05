class ApplicationController < ActionController::Base

  before_filter :get_sub_menu,:set_user
  
  protected
  
  def create_haiku(text)
    @haiku = Haiku.new
    @haiku.text = params[:haiku][:text]

    yield(@haiku)
    
    if @haiku.save
      render :partial => 'shared/haiku', :locals => { :haiku => @haiku }
    else
      render :text => "", :layout => false
    end
  end
  
  def paginated_haikus(options = {})
    Haiku.find(:all, (options.merge({:page => {:current => params[:page]}})))
  end
  
  private

  def get_sub_menu
    @sub_menu = []
  end
    
  def set_user
    @user = User.find_by_id(session[:user_id])
  end  
  
  def authorize
    unless @user = User.find_by_id(session[:user_id])
      session[:original_uri] = request.request_uri
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login", :action => "index")
    end
  end
end