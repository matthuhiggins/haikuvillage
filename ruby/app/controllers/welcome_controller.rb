class WelcomeController < ApplicationController
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  
  def index
    @haikus = paginated_haikus(:order => "id desc")
  end
  
  def next
    @haiku = Haiku.find(:first, :order => "id desc")
  end

end