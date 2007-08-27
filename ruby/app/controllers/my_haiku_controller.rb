class MyHaikuController < ApplicationController
  layout "haikus"

  before_filter :authorize
  
  def new
    if request.post?
      @haiku = Haiku.new()
      @haiku.text = params[:haiku][:text]
      @haiku.user_id = session[:user_id]
      if @haiku.save
        flash[:notice] = "Your Haiku has been saved"
        redirect_to :action => 'index'
      else
        logger.debug("failed to save")
      end
    end
  end  
  
  def favorites
    @haikus = Haiku.find(:all,
      :page => {:current => params[:page]},
      :conditions => ["hf.user_id = ?", session[:user_id]],
      :joins => "join haiku_favorites hf on haikus.id = hf.haiku_id",
      :select => "haikus.*")
      
    render :action => "index"
  end
  
  def groups
    @groups = User.find(session[:user_id]).groups
  end
  
  def index
    @haikus = Haiku.find(:all,
      :page => {:current => params[:page]},
      :conditions => {:user_id => session[:user_id]})
  end
  
  def tags
    @tags = Tag.get_tags_for_user(session[:user_id])
  end
  
  def add_haiku_to_favorites
    @haiku = Haiku.find(params[:id])
    @haiku.haiku_favorites.create(:user_id => session[:user_id])
  end
  
  def remove_haiku_from_favorites
    HaikuFavorite.delete_all("user_id = #{session[:user_id]} and haiku_id = #{params[:id]}")
    @haiku = Haiku.update(params[:id],  :haiku_favorites_count =>  "haiku_favorites_count - 1")
  end
  
  def add_tags_to_haiku
    tags = params[:tags]
    tags.split.each do |tag|
      Tag.add_haiku_tag(tag, params[:id])
    end
    @haiku = Haiku.find(params[:id])
  end
  
  private
  
  def get_sub_menu
    @sub_menu = [
      ["My Stuff", "index"],
      ["Create", "new"],
      ["My Favorites", "favorites"]
    ]
  end
  
end