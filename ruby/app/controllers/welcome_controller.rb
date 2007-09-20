class WelcomeController < ApplicationController
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
    
  def index
    @haikus = paginated_haikus(:order => "id desc")
    @title = "Create your haiku"
    render :template => "templates/input"
  end
  
  def next
    @haiku = Haiku.find(:first, :order => "id desc")
  end
  
  def create
    create_haiku(params[:haiku][:text]) do |haiku|
      haiku.user_id = User.get_anonymous.id
    end
  end

end