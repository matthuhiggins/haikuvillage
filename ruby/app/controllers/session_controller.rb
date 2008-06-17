class SessionController < ApplicationController  
  def create
    author = Author.authenticate(params[:session][:username], params[:session][:password])
    session[:username] = author ? author.username : nil
    
    if session[:username]
      if params[:haiku]
        haiku = Haiku.new(params[:haiku])
        raise InvalidHaikuException unless haiku.valid_syllables?
        author.haikus << haiku
        redirect_to :controller => 'journal'
      else
        redirect_to referring_uri
      end
    else
      flash[:notice] = "Invalid username/password combination"
      redirect_to referring_uri
    end
  end

  def destroy
    session[:username] = nil
    flash[:notice] = "You are signed out"
  end
end