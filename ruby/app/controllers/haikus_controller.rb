class HaikusController < ApplicationController
  def create
    Haiku.create!(:text => params[:haiku][:text], :user => current_user)
    redirect_to create_url
  end
  
  def new
    @title = "Create your haiku"
    input_haikus(current_user.haikus.recent)
  end
  
  def index
    @title = "Recent Haikus"
    list_haikus(Haiku.recent)
  end
  
  def popular
    @title = "Popular haikus"
    list_haikus(Haiku.popular)
  end
end