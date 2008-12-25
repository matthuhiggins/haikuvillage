class AuthorsController < ApplicationController
  def index
    if params[:q]
      render_search(params[:q])
    else
      @active_authors = Author.active.all(:limit => 12)
      @new_authors = Author.brand_new.all(:limit => 12)
      @popular_authors = Author.popular.all(:limit => 40)
    end
  end
  
  def show
    @author = Author.find_by_username(params[:id])
    @haikus = @author.haikus.paginate({
      :order     => "haikus.id desc",
      :include   => :author,
      :page      => params[:page],
      :per_page  => 10,
      :total_entries => @author.haikus_count_total
    })
  end
  
  def suggest
    @authors = Author.search(params[:q]).popular.all(:limit => 12)
  end

  private
    def render_search(query)
      if Author.find_by_username(query)
        redirect_to :action => 'show', :id => query
      else
        @authors = Subject.search(query).popular.all(:limit => 20)
        render :action => 'search'
      end
    end
end