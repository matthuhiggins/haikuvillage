class AuthorsController < ApplicationController
  def show
    list_haikus(Author.find_by_username(params[:id]), :haikus, :title => "Haikus by #{params[:id]}", :cached_total => :haikus_count_total)
  end
  
  # def favorites
    # list_haikus(Author.find_by_username(params[:id]), :favorites, :title => "Haikus that #{params[:id]} likes", :cached_total => :haikus_count)
  # end
end