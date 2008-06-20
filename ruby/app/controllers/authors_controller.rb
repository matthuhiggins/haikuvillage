class AuthorsController < ApplicationController  
  def index
    @active_authors = Author.active.all(:limit => 12)
    @new_authors = Author.brand_new.all(:limit => 12)
    @popular_authors = Author.popular.all(:limit => 40)
  end
  
  def show
    @author = Author.find_by_username(params[:id])    
    list_haikus(@author.haikus, :title => "Haikus by #{params[:id]}", :cached_total => @author.haikus_count_total)
  end
end