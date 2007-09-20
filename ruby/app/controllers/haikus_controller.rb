class HaikusController < ApplicationController
  set_sub_menu [
        ["Haikus", "index"],
        ["Search", "search"]]
  
  def index
    render_paginated
  end
  
  def popular
    render_paginated{ paginated_haikus(:order => "haiku_favorites_count desc") }
  end
  
  def recent
    render_paginated{ paginated_haikus(:order => "created_at desc") }
  end
  
  def search
    unless params[:q].blank?
      render_paginated(:search) do
        page = params[:page] || 1
        Haiku.paginating_ferret_search(:q => params[:q], :current => page.to_i, :page_size => 4)
      end
    end
  end
  
  def user
    @title = "Haikus by " + User.find(params[:id]).alias 
    render_paginated do
      paginated_haikus(:conditions => ["user_id IN (?)", params[:id]])
    end
  end
  
  def render_paginated(action = :index)
    @haikus = block_given? ? yield : paginated_haikus
    if params[:page]
      render :partial => 'shared/haikus_paginated', :locals => { :haikus => @haikus }
    else
      render :action => action
    end
  end
end