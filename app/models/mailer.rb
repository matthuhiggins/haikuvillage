class Mailer < ActionMailer::Base
  default(
    from: "575@haikuvillage.com",
    reply_to: "noreply@haikuvillage.com",
    content_type:  "text/plain"
  )    
  
  def new_friend(email, author)
    @author = author
    mail(
      to: parse_emails(email), 
      subject: "#{author.username} added you to their Haiku Village friends"
    )
  end
  
  def conversation_notice(haiku, responder)
    @haiku = haiku
    mail(
      to: haiku.author.email,
      subject: "#{responder.username} started a conversation with one of your haikus"
    )
  end

  def message_notification(message)
    @message = message
    mail(
      to: message.recipient.email,
      subject: "#{message.sender.username} sent you a message from Haiku Village"
    )
  end
  
  def password_reset(password_reset)
    @password_reset = password_reset
    mail(
      to: password_reset.author.email,
      subject: "Reset your Haiku Village password" 
    )
  end
  
  private
    def parse_emails(email_string)
      email_string.split(/,| |\n/).delete_if { |email| email.blank? }
    end
end
