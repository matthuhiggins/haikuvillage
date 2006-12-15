class MyHaikuController < ApplicationController
  layout "haikus"
  
  #before_filter :authorize
  
  def index
  end
  
  def tags
  end
  
  def favorites
  end
  
  def add_tags_to_haiku
  end
  
  private
  
  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => :index
  end

end