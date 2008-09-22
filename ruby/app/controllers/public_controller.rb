class PublicController < ApplicationController    
  def index
    @total_haikus = Haiku.count(:id)
    @total_subjects = Subject.count(:id)
    @total_authors = Author.count(:id)
    
    @popular_subjects = Subject.popular.all(:limit => 16)
    @meta_description = "Making haikus has never been easier. Welcome to a haiku community where counting syllables is done for you."
  end
  
  def sitemap
    @last_haiku = Haiku.recent.first
  end
  
  def google_gadget
    @random_haiku = Haiku.all(:limit => 10, :order => 'created_at desc').rand
    render :layout => false
  end
  
  def register
    if request.post?
      @haiku = Haiku.new(params[:haiku])
      raise InvalidHaikuException unless @haiku.valid_syllables?
      @author = Author.new(params[:author])
    
      if @author.save
        @author.haikus = [@haiku]
        session[:username] = @author.username
        flash[:new_haiku_id] = @haiku.id
        redirect_to :controller => 'journal'
      end
    else
      @haiku = Haiku.new(flash[:new_haiku])
    end
  end
end