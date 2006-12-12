class HaikusController < ApplicationController
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    @haikus = HaikuSearch.get_haikus
  end

  def new
    if request.post?
      @haiku = Haiku.new()
      @haiku.title = params[:haiku][:title]
      @haiku.text = params[:haiku][:text]
      @haiku.user_id = session[:user_id]
      
      logger.debug("saving")
      if @haiku.save
        flash[:notice] = "great success"
        redirect_to :action => 'index'
      else
        logger.debug("done saving")
      end
    end
  end
  
  def delete
    Haiku.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
  
  def tags
    if params[:id]
      @haikus = Haiku.get_haikus_by_tag_name
      render :action => "list"
    else
      @populartags = Tag.get_popular_tags
      @recenttags = Tag.get_popular_tags
    end
  end
end