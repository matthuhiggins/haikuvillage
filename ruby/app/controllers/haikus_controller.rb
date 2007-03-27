class HaikusController < ApplicationController
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    @haikus = Haiku.find(:all,
                         :page => {:current => params[:page]})
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
    @haikus = Haiku.find(:all,
                         :page => {:curent => params[:page]},
                         :order => "haiku_favorites_count desc")
    render :action => "index"
  end
  
  def recent
    @haikus = Haiku.find(:all, 
                         :page => {:curent => params[:page]},
                         :order => "created_at desc")
    render :action => "index"
  end
  
  def search
    unless params[:q].blank?
      current = 1 unless params[:p]
      @haikus = Haiku.paginating_ferret_search({:q => params[:q],
                                                :current => 1,
                                                :page_size => 10})
    end
  end
  
  private
  
  def get_sub_menu
    @sub_menu = %w{ index favorites recent search }
  end
    
end