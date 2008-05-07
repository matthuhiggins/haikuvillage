class HaikusController < ApplicationController
  set_sub_menu [
        ["Recent", "index"],
        ["Popular", "popular"]]
  
  def create
    Haiku.create!(:text => params[:haiku][:text],
                 :user => current_user)
    render :text => 'success'
  end
  
  def index
    render_paginated
  end
  
  def popular
    render_paginated{ paginated_haikus(:order => "haiku_favorites_count desc") }
  end
  
  def recent
    render_paginated{ paginated_haikus(:order => "created_at desc") }
  end
  
  def render_paginated(template = "listing")
    @haikus = block_given? ? yield : paginated_haikus
    if params[:page]
      render :partial => 'shared/haikus_paginated', :locals => { :haikus => @haikus }
    else
      render :template => "templates/#{template}"
    end
  end
end