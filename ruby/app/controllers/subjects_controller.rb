class SubjectsController < ApplicationController
  def index
    if params[:q]
      if Subject.find_by_name(params[:q])
        redirect_to :action => 'show', :id => params[:q]
      else
        @subjects = Subject.search(params[:q]).popular
        render :action => 'search'
      end
    else
      @popular_subjects = Subject.popular
      @new_subjects = Subject.recent
    end
  end
  
  def show
    subject = Subject.find_by_name(params[:id])
    list_haikus(subject.haikus, :title => "#{params[:id]} Haikus", :cached_total => subject.haikus_count_total)
  end
  
  def suggest
    @subjects = Subject.search(params[:q]).popular
  end
end