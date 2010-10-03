class PasswordResetsController < ApplicationController
  def create
    #   PasswordReset.create(:login => params[:login])
    #   flash[:notice] = "You will receive an email with instructions."
    #   redirect_to(login_path)
    # rescue ActiveRecord::RecordNotFound
    #   flash[:notice] = "We could not find an author with #{params[:login]}."
    # 
    @password_reset = PasswordReset.create(params[:password_reset])
  end

  def show
    # @password_reset = 
  end
  
  def reset_password
    @password_reset = PasswordReset.find_by_token!(params[:token])
    if request.post?
      session[:author_id] = @password_reset.author.id
      @password_reset.destroy
      @password_reset.author.update_attributes(:password => params[:password])
      flash[:notice] = "Your new password has been saved"
      redirect_to(journal_path)
    end
  end
end