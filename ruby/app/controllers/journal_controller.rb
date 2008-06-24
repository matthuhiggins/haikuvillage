class JournalController < ApplicationController
  login_filter
  
  def index
    @recent_haikus = current_author.haikus.recent.all(:limit => 3, :include => :author)
  end
  
  def favorites
    @meta_description = "A listing of your favorite haikus"
    list_haikus(current_author.favorites, :title => "Your favorite haikus", :cached_total => current_author.favorites_count)
  end
  
  def haikus
    @meta_description = "A listing of haikus that you created"
    list_haikus(current_author.haikus, :title => "Haikus you created", :cached_total => current_author.haikus_count_total)
  end
end