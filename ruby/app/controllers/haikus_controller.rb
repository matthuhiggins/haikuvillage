class HaikusController < ApplicationController
  set_sub_menu [
        ["Recent", "index"],
        ["Popular", "popular"]]
  
  def create
    Haiku.create!(:text => params[:haiku][:text],
                 :user => current_user)
    redirect_to create_url
  end
  
  def new
    
  end
  
  def index
    render_paginated
  end

  alias :index :popular
  
  def popular
    render_paginated{ paginated_haikus(:order => "haiku_favorites_count desc") }
  end
  
  def render_paginated(template = "listing")
    @haikus = Haiku.recent
    if params[:page]
      render :partial => 'shared/haikus_paginated', :locals => { :haikus => @haikus }
    else
      render :template => "templates/#{template}"
    end
  end
end