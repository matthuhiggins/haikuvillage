class WelcomeController < ApplicationController
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  
  def index
    @haikus = Haiku.find(:all, :order => "id desc", :limit => 5)
  end
  
  def next
    @haiku = Haiku.find(:first, :order => "id desc")
  end

end