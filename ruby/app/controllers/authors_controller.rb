class AuthorsController < ApplicationController  
  def index
    @meta_description = "Haiku organized by author"
    @active_authors = Author.active.all(:limit => 12)
    @new_authors = Author.brand_new.all(:limit => 12)
    @popular_authors = Author.popular.all(:limit => 40)
  end
  
  def show
    @author = Author.find_by_username(params[:id])
    @meta_description = "A collection of #{@author.haikus_count_total} haikus by #{params[:id]}"
    list_haikus(@author.haikus, :title => "Haikus by #{params[:id]}", :cached_total => @author.haikus_count_total)
  end
end