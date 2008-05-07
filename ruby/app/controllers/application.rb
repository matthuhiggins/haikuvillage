class ApplicationController < ActionController::Base
  class << self
    def set_sub_menu(menu_items)
      write_inheritable_attribute "menu_items", menu_items
    end
    
    def sub_menu
      @menu_items ||= read_inheritable_attribute("menu_items") || []
    end
  end
  
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  
  before_filter :set_user
  
  def sub_menu
    self.class.sub_menu
  end
  
  protected
    def create_haiku(text)
      if @haiku.save
        render :partial => 'shared/haiku', :object => haiku
      else
        render :text => "", :layout => false
      end
    end
  
    def paginated_haikus(options = {})
      options[:page] = {:current => params[:page] || 1}
      Haiku.find(:all, options)
    end
  
  private
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