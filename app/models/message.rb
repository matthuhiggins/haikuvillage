class Message < ActiveRecord::Base
  class << self
    def transmit(sender, recipient, text)
      sender.messages.create(:text => text, :unread => false, :sender => sender, :recipient => recipient)
      sent_message = recipient.messages.create(:text => text, :unread => true, :sender => sender, :recipient => recipient)
      Mailer.deliver_message_notification(sent_message)
    end
  end
  
  belongs_to :author
  belongs_to :sender, :class_name => "Author"
  belongs_to :recipient, :class_name => "Author"
  
  default_scope :order => 'id desc'
  named_scope :unread, :conditions => {:unread => true}

  def terse
    text.gsub(/\n/, ' / ')
  end
  
  def other_author
    author_id == sender_id ? recipient : sender
  end
end