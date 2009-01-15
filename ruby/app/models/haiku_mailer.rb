class HaikuMailer < ActionMailer::Base
  def haiku(haiku, email, author)
    @recipients   = email
    @from         = "575@haikuvillage.com"
    headers         "Reply-to" => "noreply@haikuvillage.com"
    @subject      = "#{author.username} sent you a haiku from HaikuVillage"
    @sent_on      = Time.now
    @content_type = "text/plain"
    
    body[:haiku] = haiku
    body[:author] = author
  end
    
end
