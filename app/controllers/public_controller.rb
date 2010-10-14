class PublicController < ApplicationController
  prevent_logged_in only: [:index, :register]

  def index
    if current_author
      redirect_to :controller => "journal"
    else
      active_authors = Author.recently_updated.limit(10)
      @haikus = Haiku.where(id: active_authors.map(&:latest_haiku_id)).includes([:conversation, :author])
      @total_haikus = Haiku.count(:id)
      @total_subjects = Subject.count(:id)
      @total_authors = Author.count(:id)
    end
  end
  
  def google_gadget
    @random_haiku = Haiku.recent.limit(10).sample
    render :layout => false
  end
  
  def register
    if request.post?
      @author = Author.new(params[:author])

      if @author.save
        login_and_redirect(@author)
      end
    else
      @author = Author.new
    end
  end
end