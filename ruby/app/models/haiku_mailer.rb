class HaikuMailer < ActionMailer::Base

  def send_haiku(sent_at = Time.now)
    @subject    = 'HaikuMailer#send_haiku'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end
end