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
    
  def sub_menu
    self.class.sub_menu
  end
  
  protected
  
    def paginated_haikus(options = {})
      # options[:page] = {:current => params[:page] || 1}
      Haiku.find(:all, options)
    end
  
  private
    def current_user
      User.find(session[:user_id])
    end
    helper_method :current_user
end