class AuthorsController < ApplicationController
  prevent_logged_in :only => [:new, :create]

  def index
    @active_authors = Author.active.limit(12)
    @new_authors = Author.brand_new.limit(12)
    @popular_authors = Author.popular.limit(40)
  end
  
  def new
    @author = Author.new
  end
  
  def create
    @author = Author.new(params[:author])
    if @author.save
      login(@author)
      redirect_to :controller => "journal"
    else
      render "new"
    end
  end

  def show
    @author = Author.find_by_username!(params[:id])
    
    respond_to do |f|
      f.html do
        @haikus = @author.haikus.recent.page(params[:page]).per(10)
        # :total_entries => @author.haikus_count_total
      end
      f.atom { render_atom(@author.haikus.recent.limit(10)) }
      f.text { render :text => @author.haikus.map{|haiku| haiku.text}.join("\n\n") }
    end
  end
  
  def friends
    @author = Author.find_by_username!(params[:id])
    @friends = @author.friends.recently_updated.includes(haikus: :conversation)
  end
end