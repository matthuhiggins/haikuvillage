class MyController < ApplicationController
  login_filter
  
  def index
    @haikus = current_author.haikus.recent.all(:limit => 4, :include => :author)    
  end
end