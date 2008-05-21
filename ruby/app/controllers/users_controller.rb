class UsersController < ApplicationController
  def show
    list_haikus(User.find_by_username(params[:id]), :haikus, :title => "Haikus by #{params[:id]}", :cached_total => :haikus_count)
  end
  
  # def favorites
    # list_haikus(User.find_by_username(params[:id]), :favorites, :title => "Haikus that #{params[:id]} likes", :cached_total => :haikus_count)
  # end
end