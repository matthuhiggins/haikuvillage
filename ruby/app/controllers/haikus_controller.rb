class HaikusController < ApplicationController
  def create
    Haiku.create!(:text => params[:haiku][:text],
                 :user => current_user)
    redirect_to create_url
  end
  
  def new
    @haikus = current_user.haikus.recent
    @title = "Create your haiku"
    render :template => "templates/input"
  end
  
  def index
    @haikus = Haiku.recent
    @title = "Recent Haikus"
    render :template => "templates/listing"
  end
  
  def popular
    @haikus = Haiku.popular
    @title = "Popular haikus"
    render :template => "templates/listing"
  end
end