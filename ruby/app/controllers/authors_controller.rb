class AuthorsController < ApplicationController
  class InvalidHaikuException < StandardError
  end
  
  def show
    @author = Author.find_by_username(params[:id])    
    list_haikus(@author.haikus, :title => "Haikus by #{params[:id]}", :cached_total => @author.haikus_count_total)
  end
  
  def index
    @active_authors = Author.active.all(:limit => 10)
    @brand_new_authors = Author.brand_new.all(:limit => 10)
  end
  
  def create
    @haiku = Haiku.new(params[:haiku])
    raise InvalidHaikuException unless @haiku.valid_syllables?
    @author = Author.new(params[:author])
    
    if @author.save && (@author.haikus << @haiku)
      session[:username] = @author.username
      flash[:notice] = 'Registration successful'
      redirect_to :controller => 'journal'
    else
      render :action => 'new'
    end
  end
end