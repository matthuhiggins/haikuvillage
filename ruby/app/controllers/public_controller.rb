class PublicController < ApplicationController    
  def index
    if current_author
      redirect_to create_url
    else
      @recent_haikus = Haiku.recent.all(:limit => 2, :include => :author)
      @total_haikus = Haiku.count(:id)
      @total_subjects = Subject.count(:id)
      @total_authors = Author.count(:id)
    end
  end
  
  def sitemap
    @last_haiku = Haiku.recent.first
  end
end