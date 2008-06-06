class PublicController < ApplicationController    
  def index
    if current_author
      redirect_to create_url
    else
      @haikus = Haiku.recent.all(:limit => 4, :include => :author)
    end
  end
  
  def sitemap
    @last_haiku = Haiku.recent.first
  end
end