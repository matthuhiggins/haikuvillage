class SubjectsController < ApplicationController
  def index
    @meta_description = "Haiku organized by subject"
    if params[:q]
      render_search(params[:q])
    else
      @hot_subjects = Subject.hot.all(:limit => 12)
      @new_subjects = Subject.recent.all(:limit => 12)
      @popular_subjects = Subject.popular.all(:limit => 40)
    end
  end
  
  def show
    subject = Subject.find_by_name(params[:id])
    @meta_description = "A collection of #{subject.haikus_count_total} haikus about the subject of #{params[:id]}"
    list_haikus(subject.haikus, :title => "#{params[:id]} Haikus", :cached_total => subject.haikus_count_total)
  end
  
  def suggest
    @subjects = Subject.search(params[:q]).popular.all(:limit => 12)
  end
  
  private
    def render_search(query)
      if Subject.find_by_name(query)
        redirect_to :action => 'show', :id => query
      else
        @subjects = Subject.search(query).popular.all(:limit => 20)
        render :action => 'search'
      end
    end
end