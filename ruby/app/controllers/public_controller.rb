class PublicController < ApplicationController    
  def index
    if current_author
      redirect_to :controller => "journal"
    else
      @haikus = Haiku.global_feed
      @total_haikus = Haiku.count(:id)
      @total_subjects = Subject.count(:id)
      @total_authors = Author.count(:id)
    end
  end
  
  def sitemap
    @last_haiku = Haiku.recent.first
  end
  
  def google_gadget
    @random_haiku = Haiku.all(:limit => 10, :order => 'created_at desc').rand
    render :layout => false
  end
  
  def register
    @haiku = Haiku.new(session[:new_haiku])
    if request.post?
      @author = Author.new(params[:author])

      if @author.save
        session[:username] = @author.username
        @author.haikus << @haiku
        redirect_to(original_login_referrer)
      end
    end
  end
end