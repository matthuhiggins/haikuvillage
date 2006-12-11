class HaikusController < ApplicationController
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    @haikus = Haiku.get_haikus
  end

  def new
    @haiku = Haiku.new
  end

  def delete
    Haiku.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
  
  def add_haiku
    @haiku = Haiku.new(params[:haiku])
    @haiku.user_id = session[:user_id]

    #logger.debug("text: " + @haiku_view.haiku_text.inspect)
    #logger.debug("the content: " + @haiku_view.inspect)    

    @haiku.save!
    redirect_to :action => 'list'
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