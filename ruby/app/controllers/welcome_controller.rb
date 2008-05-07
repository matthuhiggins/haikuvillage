class WelcomeController < ApplicationController    
  def index
    @haikus = Haiku.recent
    @title = "Create your haiku"
    @refresh = true
    render :template => "templates/input"
  end
  
  def next
    @haiku = Haiku.find(:first, :order => "id desc")
    if @haiku
      render :partial => 'shared/haiku', :locals => { :haiku => @haiku }
    else
      render :text => "", :layout => false
    end
  end
end