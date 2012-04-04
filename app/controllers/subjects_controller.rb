class SubjectsController < ApplicationController
  def index
    if params[:q]
      render_search(params[:q])
    else
      @hot_subjects = Subject.hot.limit(12)
      @new_subjects = Subject.recent.limit(12)
      @popular_subjects = Subject.popular.limit(40)
    end
  end
  
  def show
    @subject = Subject.find(params[:id])
    @haikus = @subject.haikus.recent.page(params[:page]).per(10)
      # :total_entries => @subject.haikus_count_total
  end
  
  def suggest
    @subjects = Subject.search(params[:q]).popular.all(:limit => 12)
  end
  
  private
    def render_search(query)
      if subject = Subject.find_by_name(query)
        redirect_to subject
      else
        @subjects = Subject.search(query).popular.limit(10)
        render 'search'
      end
    end
end