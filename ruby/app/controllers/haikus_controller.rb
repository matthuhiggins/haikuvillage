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
    @title = "Recent Haikus"
    render_paginated
  end
  
  def popular
    @haikus = Haiku.popular
    @title = "Popular haikus"
    render :template => "templates/listing"
  end
end