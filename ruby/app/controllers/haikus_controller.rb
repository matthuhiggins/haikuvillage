class HaikusController < ApplicationController
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    @haikus = HaikuSearch.get_haikus
  end
  
  def tags
    if params[:id]
      @haikus = HaikuSearch.get_haikus_by_tag_name(params[:id])
      render :action => "index"
    else
      @populartags = Tag.get_popular_tags
      @recenttags = Tag.get_recent_tags
    end
  end
  
  def favorites
    @haikus = HaikuSearch.get_haikus_by_popularity
    render :action => "index"
  end
  
  def recent
    @haikus = HaikuSearch.get_haikus_by_created_at
    render :action => "index"
  end
  
  def search
    if request.post? and not params[:search].blank?
      @haikus = Haiku.find_by_contents(params[:search][:text])
    end
  end
  
  private
  
  def get_sub_menu
    @sub_menu = %w{ index favorites recent search }
  end
    
end