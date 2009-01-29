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
  
  def create
    @author = Author.new(params[:author])
    if @author.save
      session[:username] = @author.username
      redirect_to :controller => "journal"
    else
      redirect_to(:back)
    end
  end

  def show
    @author = Author.find_by_username!(params[:id])
    @haikus = @author.haikus.recent.paginate({
      :page      => params[:page],
      :per_page  => 10,
      :total_entries => @author.haikus_count_total
    })
  end
  
  def invite
    return if request.get?
    HaikuMailer.deliver_invite(params[:email], current_author)
    flash[:notice] = "The invite has been sent"
    redirect_to journal_url
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