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

  def feedback
    if request.post?
      flash[:notice] = "Thanks for your feedback!"
      Mailer.deliver_feedback(params[:feedback])
      redirect_to root_path
    end
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

      if @author.save
        login_and_redirect(@author)
      end
    end
  end
end