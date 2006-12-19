class HaikusController < ApplicationController
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    @haikus = HaikuSearch.get_haikus
  end
  
  def show
    @haiku = Haiku.find(params[:id])
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
      @haikus = HaikuSearch.get_haikus_by_tag_name(params[:id])
      render :action => "index"
    else
      @populartags = Tag.get_popular_tags
      @recenttags = Tag.get_recent_tags
    end
  end
  
  def favorites
    @haikus = HaikuSearch.get_haikus_by_popularity
    render :action => "index"
  end
  
  def recent
    @haikus = HaikuSearch.get_haikus_by_created_at
    render :action => "index"
  end
    
  def add_haiku_to_favorites
    @haiku = Haiku.find(params[:id])
    @haiku.haiku_favorites.create(:user_id => session[:user_id])
  end
  
  def remove_haiku_from_favorites
    HaikuFavorite.delete_all("user_id = #{session[:user_id]} and haiku_id = #{params[:id]}")
    @haiku = Product.update(params[:id],  "haiku_favorites_count = haiku_favorites_count - 1")
  end
  
  def add_tags_to_haiku
    tags = params[:tags]
    @haiku = Haiku.find(params[:id])
    tags.split.each do |tag|
      Tag.add_haiku_tag(tag, @haiku)
    end
  end
  
  def add_comment
    @haiku = Haiku.find(params[:haiku][:id])
    comment = @haiku.comments.new(params[:comment])
    comment.haiku = @haiku
    comment.user_id = session[:user_id]
    comment.save
    redirect_to :back
  end
  
  def delete_comment
    HaikuComment.delete(params[:id])
    redirect_to :back
  end
end