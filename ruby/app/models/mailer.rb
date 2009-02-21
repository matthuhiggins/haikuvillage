class Mailer < ActionMailer::Base
  def haiku(haiku, email, author)
    configure_defaults  
    recipients    parse_emails(email)
    subject       "#{author.username} shared you a haiku from HaikuVillage"
    body          :haiku => haiku, :author => author
  end
  
  def new_friend(email, author)
    configure_defaults  
    recipients    parse_emails(email)
    subject       "#{author.username} added you to their HaikuVillage friends"
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

  def message_notification(message)
    configure_defaults
    recipients  message.recipient.email
    subject     "#{message.sender.username} sent you a message from HaikuVillage"
    body        :message => message
  end
  
  def password_reset(password_reset)
    configure_defaults
    recipients  password_reset.author.email
    subject     "Reset your HaikuVillage password"
    body        :password_reset => password_reset
  end
  
  def group_invitation(author, group)
    configure_defaults
    recipients  author.email
    subject     "You are invited to join the HaikuVillage group #{h group.name}"
    body        :author => author, :group => group
  end
  
  def group_application(author, group)
    configure_defaults
    recipients  group.memberships.admins.map(&:email)
    subject     "#{author.username} wants to join your HaikuVillage group"
    body        :author => author, :group => group
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
