class SubjectsController < ApplicationController
  def index
    @popular_subjects = Subject.popular
    @new_subjects = Subject.recent
  end
  
  def show
    subject = Subject.find_by_name(params[:id])
    list_haikus(subject.haikus, :title => "#{params[:id]} Haikus", :cached_total => subject.haikus_count_total)
  end
  
  def suggest
    @subjects = Subject.search(params[:q]).popular
  end
end