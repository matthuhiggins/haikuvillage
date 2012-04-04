class PasswordResetsController < ApplicationController
  def index
    @password_reset = PasswordReset.new
  end

  def create
    PasswordReset.create(login: params[:login])
    flash[:notice] = "You will receive an email with instructions."
    redirect_to(login_path)
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "We could not find an author with #{params[:login]}."
    redirect_to password_resets_path
  end

  def show
    @password_reset = PasswordReset.find_by_token!(params[:id])
  end

  def update
    @password_reset = PasswordReset.find_by_token!(params[:id])

    if @password_reset.update_attributes(params[:password_reset])
      @password_reset.destroy
      flash[:notice] = "Your new password has been saved"
      login_and_redirect(@password_reset.author)
    else
      render 'show'
    end
  end  
end
