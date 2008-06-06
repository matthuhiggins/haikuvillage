class AuthorsController < ApplicationController
  def show
    @author = Author.find_by_username(params[:id])    
    list_haikus(@author.haikus, :title => "Haikus by #{params[:id]}", :cached_total => @author.haikus_count_total)
  end
  
  def index
    @active_authors = Author.active.all(:limit => 10)
    @brand_new_authors = Author.brand_new.all(:limit => 10)
  end
end