class PublicController < ApplicationController    
  def index
    @recent_haikus = Haiku.recent.all(:limit => 2, :include => :author)
    @total_haikus = Haiku.count(:id)
    @total_subjects = Subject.count(:id)
    @total_authors = Author.count(:id)
  end
  
  def sitemap
    @last_haiku = Haiku.recent.first
  end
end