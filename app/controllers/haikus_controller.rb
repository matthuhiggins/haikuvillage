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
  
  def tags
    @tags = Tag.get_popular_tags
  end

  def show
    @haiku = HaikuView.from_haiku(Haiku.find(params[:id]))
  end

  def new
    @haiku = HaikuView.new
  end

  def edit
    @haiku = HaikuView.from_haiku(Haiku.find(params[:id]))
  end

  def update
    @haiku = Haiku.find(params[:id])
    if @haiku.update_attributes(params[:haiku])
      flash[:notice] = 'Haiku was successfully updated.'
      redirect_to :action => 'show', :id => @haiku
    else
      render :action => 'edit'
    end
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
    if @haiku.save 
      flash[:notice] = @haiku.title
      redirect_to :action => 'show', :id => @haiku
    else
      flash[:notice] = 'Haiku was not saved!'    
    end
  end
  
  
end
