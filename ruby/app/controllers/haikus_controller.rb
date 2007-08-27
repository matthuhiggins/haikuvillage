class HaikusController < ApplicationController
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    render_index
  end
  
  def popular
    render_index{ paginated_haikus(:order => "haiku_favorites_count desc") }
  end
  
  def recent
    render_index{ paginated_haikus(:order => "created_at desc") }
  end
  
  def search
    unless params[:q].blank?
      current = 1 unless params[:p]
      @haikus = Haiku.paginating_ferret_search({:q => params[:q],
                                        :current => 1,
                                        :page_size => 4})
    end
  end
  
  def get_sub_menu
    @sub_menu = [
      ["Haikus", "index"],
      ["Popular", "popular"],
      ["Recent", "recent"],
      ["Search", "search"]
    ]
  end
  
  def render_index
    @haikus = block_given? ? yield : paginated_haikus
    if params[:page]
      render :partial => 'shared/haikus'
    else
      render :action => :index
    end    
  end
end