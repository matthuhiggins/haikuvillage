class HaikusController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @haikus = Haiku.get_haikus.map{|haiku| HaikuView.from_haiku(haiku)}
  end

  def new
    @haiku = HaikuView.new
  end

  def destroy
    Haiku.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def add_haiku
    @haiku_view = HaikuView.new(params[:haiku][:title], params[:haiku][:haiku_text])
    logger.debug("text: " + @haiku_view.haiku_text.inspect)
    logger.debug("the content: " + @haiku_view.inspect)
    @haiku = Haiku.from_haiku_view(@haiku_view)
    
    @haiku.user_id = 2 #TODO: replace this with actual user association
    
    if @haiku.save 
      flash[:notice] = @haiku.title
      redirect_to :action => 'list'
    else
      flash[:notice] = 'Haiku was not saved!'  
      redirect_to :action => 'new'
      new
    end
  end
  
  def tags
    if params[:id]
      @haikus = Haiku.get_haikus_by_tag_name(params[:id]).map{|haiku| HaikuView.from_haiku(haiku)}
      render :action => "list"
    else
      @populartags = Tag.get_popular_tags
      @recenttags = Tag.get_popular_tags
    end
  end  
end