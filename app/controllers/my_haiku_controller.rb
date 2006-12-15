class MyHaikuController < ApplicationController
  layout "haikus"
  
  before_filter :authorize
  
  def index
  end
  
  def tags
  end
  
  def favorites
  end
  
  def add_tags_to_haiku
  end

  def add_haiku_to_favorites
    begin                     
      haiku = Haiku.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid haiku #{params[:id]}")
      redirect_to_index("Invalid product")
    else
      haiku.haiku_favorites.create(:user_id => session[:user_id])
      redirect_to_index
    end
  end
  
  private
  
  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => :index
  end    

end