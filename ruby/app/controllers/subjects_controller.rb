class SubjectsController < ApplicationController
  def index
    @popular_subjects = Subject.popular
    @new_subjects = Subject.recent
  end
  
  def show
    list_haikus(Subject.find_by_name(params[:id]), :haikus, :title => "#{params[:id]} Haikus", :cached_total => :haikus_count_total)
  end
  
  def suggest
    @subjects = Subject.search(params[:q]).popular
  end
end