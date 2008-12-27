class ProfileController < ApplicationController
  login_filter
  
  def index
    if request.put?
      if current_author.update_attributes(params[:author])
        session[:username] = current_author.username
        flash[:notice] = 'Account saved'
      end
    end
  end

  def update_avatar
    if current_author.update_attributes(params[:author])
      flash[:notice] = 'Avatar saved'
    end
    redirect_to :action => 'avatar'
  end

  def twitter
    if request.put?
      if !params[:author][:twitter_enabled] || Twitter.authenticate(params[:author][:twitter_username], params[:author][:twitter_password])
        current_author.update_attributes(params[:author])
        flash[:notice] = "Twitter settings saved"
      else
        flash[:notice] = "Wrong Twitter username and password"
      end
    end
  end

  def password
    if request.put?
      if current_author.authenticate(params[:current_password])
        if current_author.update_attributes(:password => params[:password])
          flash[:notice] = "Password successfully changed"
        end
      else
        flash[:notice] = 'Wrong current password'
      end
    end
  end
end