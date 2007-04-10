class WelcomeController < ApplicationController
  layout "haikus"
  
  def index
    @haiku = Haiku.find(:first, :order => "created_at desc")
  end

end