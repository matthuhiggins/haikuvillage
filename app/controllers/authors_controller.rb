class AuthorsController < ApplicationController
  def index
    @active_authors = Author.active.all(:limit => 12)
    @new_authors = Author.brand_new.all(:limit => 12)
    @popular_authors = Author.popular.all(:limit => 40)
  end
  
  def create
    @author = Author.new(params[:author])
    if @author.save
      session[:author_id] = @author.id
      redirect_to :controller => "journal"
    else
      render "new"
    end
  end

  def show
    @author = Author.find_by_username!(params[:id])
    
    respond_to do |f|
      f.html do
        @haikus = @author.haikus.recent.paginate({
          :page      => params[:page],
          :per_page  => 10,
          :total_entries => @author.haikus_count_total
        })
      end
      f.atom { render_atom(@author.haikus.recent.all(:limit => 10)) }
      f.text { render :text => @author.haikus.map{|haiku| haiku.text}.join("\n\n") }
    end
  end
  
  def friends
    @author = Author.find_by_username!(params[:id])
    @friends = @author.friends.recently_updated
  end
end