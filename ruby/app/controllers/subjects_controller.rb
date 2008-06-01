class SubjectsController < ApplicationController
  def index
    @subjects = Subject.all
  end
  
  def show
    list_haikus(Subject.find_by_name(params[:id]), :haikus, :title => "#{params[:id]} Haikus", :cached_total => :haikus_count)
  end
end