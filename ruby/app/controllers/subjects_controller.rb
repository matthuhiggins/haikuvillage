class SubjectsController < ApplicationController
  def index
    if params[:q]
      render_search(params[:q])
    else
      @hot_subjects = Subject.hot.all(:limit => 12)
      @new_subjects = Subject.recent.all(:limit => 12)
      @popular_subjects = Subject.popular.all(:limit => 40)
    end
  end
  
  def show
    @subject = Subject.find_by_name!(params[:id])
    @haikus = @subject.haikus.paginate(
      :order     => "haikus.id desc",
      :include   => :author,
      :page      => params[:page],
      :per_page  => 10,
      :total_entries => @subject.haikus_count_total
    )
  end
  
  def suggest
    @subjects = Subject.search(params[:q]).popular.all(:limit => 12)
  end
  
  private
    def render_search(query)
      if Subject.find_by_name(query)
        redirect_to :action => 'show', :id => query
      else
        @subjects = Subject.search(query).popular.all(:limit => 10)
        render 'search'
      end
    end
end