class Mailer < ActionMailer::Base
  def haiku(haiku, email, author)
    configure_defaults  
    recipients    parse_emails(email)
    subject       "#{author.username} sent you a haiku from HaikuVillage"
    body          :haiku => haiku, :author => author
  end
  
  def new_friend(email, author)
    configure_defaults  
    recipients    parse_emails(email)
    subject       "#{author.username} added you to their friends"
    body          :author => author
  end
  
  def invite(email, author)
    configure_defaults
    recipients    parse_emails(email)
    subject       "#{author.username} has invited you to join HaikuVillage!"
    body          :author => author
  end
  
  def conversation_notice(haiku, responder)
    configure_defaults
    recipients    haiku.author.email
    subject       "#{responder.username} started a conversation with one of your haikus"
    body          :haiku => haiku
  end
  
  private
    def configure_defaults
      from          "575@haikuvillage.com"
      headers       "Reply-to" => "noreply@haikuvillage.com"
      content_type  "text/plain"
    end
    
    def parse_emails(email_string)
      email_string.split(/,| |\n/).delete_if { |email| email.blank? }
    end
    
end
