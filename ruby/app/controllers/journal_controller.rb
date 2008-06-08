class JournalController < ApplicationController
  login_filter
  
  def index
    @haikus = current_author.haikus.recent.all(:limit => 4, :include => :author)
  end
  
  def favorites
    list_haikus(current_author.favorites, :title => "Your favorite haikus", :cached_total => current_author.favorites_count)
  end
  
  def haikus
    list_haikus(current_author.haikus, :title => "Haikus you created", :cached_total => current_author.haikus_count_total)
  end
end