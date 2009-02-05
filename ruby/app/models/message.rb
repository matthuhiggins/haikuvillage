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
  
  default_scope :order => 'created_at'
  named_scope :unread, :conditions => {:unread => true}
end