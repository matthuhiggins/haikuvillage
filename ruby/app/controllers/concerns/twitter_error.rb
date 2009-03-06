module Concerns::TwitterError
  def self.included(controller)
    controller.rescue_from Twitter::AuthenticationError, :with => :invalid_twitter_credentials
  end

  private
    def invalid_twitter_credentials
      flash[:notice] = "Your Twitter credentials are out of date"
      redirect_to :controller => "profile", :action => "twitter"
    end
end