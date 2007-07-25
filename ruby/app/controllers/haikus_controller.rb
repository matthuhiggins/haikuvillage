class HaikusController < ApplicationController
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    @haikus = paginated_haikus({})
  end
  
  def tags
    if params[:id]
      @haikus = paginated_haikus(
        :conditions => ["t.name = ?", params[:id]],
        :joins => "join haiku_tags ht on haikus.id = ht.haiku_id join tags t on ht.tag_id = t.id",
        :select => "haikus.*")
      render :action => "index"
    else
      @populartags = Tag.get_popular_tags
      @recenttags = Tag.get_recent_tags
    end
  end
  
  def favorites
    @haikus = paginated_haikus(:order => "haiku_favorites_count desc")
    render :action => "index"
  end
  
  def recent
    @haikus = paginated_haikus(:order => "created_at desc")
    render :action => "index"
  end
  
  def show 
    @haiku = Haiku.find(params[:id])
  end
  
  private
  
  def get_sub_menu
    @sub_menu = [
      ["Haikus", "index"],
      ["Favorites", "favorites"],
      ["Recent", "recent"],
      ["Tags", "tags"],
      ["Search", {:action => "haikus", :controller => "search"}]
    ]
  end
  
  def paginated_haikus(options)
    Haiku.find(:all, (options.merge({:page => {:current => params[:page]}})))
  end
  
    
end