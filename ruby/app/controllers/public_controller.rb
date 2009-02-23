class PublicController < ApplicationController    
  def index
    if current_author
      redirect_to :controller => "journal"
    else
      @haikus = Author.recently_updated.all(:limit => 10, :conditions => 'latest_haiku_id is not null').map { |a| a.latest_haiku }
      @total_haikus = Haiku.count(:id)
      @total_subjects = Subject.count(:id)
      @total_authors = Author.count(:id)
    end
  end
  
  def sitemap
    @last_haiku = Haiku.recent.first
  end
  
  def google_gadget
    @random_haiku = Haiku.recent.all(:limit => 10).rand
    render :layout => false
  end
  
  def register
    unless session[:new_haiku].nil?
      @haiku = Haiku.new(session[:new_haiku])
    end

    if request.post?
      @author = Author.new(params[:author])
      @author.haikus << @haiku unless @session[:new_haiku].nil?

      if @author.save
        session[:username] = @author.username
        redirect_to(original_login_referrer)
      end
    end
  end
end