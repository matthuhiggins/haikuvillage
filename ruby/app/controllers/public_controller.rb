class PublicController < ApplicationController    
  def index
    @haikus = Haiku.recent.all(:limit => 4, :include => :author)
  end
end