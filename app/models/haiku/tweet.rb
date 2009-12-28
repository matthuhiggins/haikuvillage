module Haiku::Tweet
  def self.included(base)
    base.after_create(:tweet)
  end

  private
    def tweet
      if author.twitter_enabled
        Twitter.tweet(self)
      end
    end
end