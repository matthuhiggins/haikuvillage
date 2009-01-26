class HaikuMailer < ActionMailer::Base
  def haiku(haiku, email, author)
    configure_defaults  
    recipients    email
    subject       "#{author.username} sent you a haiku from HaikuVillage"
    content_type  "text/plain"
    body          :haiku => haiku, :author => author
  end
  
  def new_friend(author, email)
    configure_defaults  
    recipients    email
    subject       "#{author.username} added you to their friends"
    content_type  "text/plain"
    body          :author => author
  end
  
  private
    def configure_defaults
      from          "575@haikuvillage.com"
      headers       "Reply-to" => "noreply@haikuvillage.com"
    end
    
end
