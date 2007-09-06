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
        current = 1 unless params[:p]
        Haiku.paginating_ferret_search(:q => params[:q], :current => 1, :page_size => 4)
      end
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