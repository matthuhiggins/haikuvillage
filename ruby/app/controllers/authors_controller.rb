class AuthorsController < ApplicationController
  def show
    author = Author.find_by_username(params[:id])
    list_haikus(author.haikus, :title => "Haikus by #{params[:id]}", :cached_total => author.haikus_count_total)
  end
  
  def index
    @authors = Author.active
  end
end