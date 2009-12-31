class ProfileController < ApplicationController
  login_filter
  
  def index
    return if request.get?

    if current_author.update_attributes(params[:author])
      flash[:notice] = 'Account saved'
    end
  end

  def twitter
    return if request.get?

    if !params[:author][:twitter_enabled] || Twitter.authenticate(params[:author][:twitter_username], params[:author][:twitter_password])
      current_author.update_attributes(params[:author])
      flash[:notice] = "Twitter settings saved"
    else
      flash[:notice] = "Wrong Twitter username and password"
    end
  end

  def password
    return if request.get?
    
    if current_author.authenticate(params[:current_password])
      if current_author.update_attributes!(:password => params[:password])
        flash[:notice] = "Password successfully changed"
      end
    else
      flash[:notice] = 'Wrong current password'
    end
  end
end