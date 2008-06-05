class PublicController < ApplicationController    
  def index
    @haikus = Haiku.recent.all(:limit => 4, :include => :author)
  end
  
  def sitemap
    @last_haiku = Haiku.recent.first
  end
end