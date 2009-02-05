class Message < ActiveRecord::Base
  class << self
    def transmit(sender, recipient, text)
      sender.create_message(:text => text, :unread => false, :sender => sender, :recipient => recipient)
      recipient.create_message(:text => text, :unread => true, :sender => sender, :recipient => recipient)
    end
  end
  
  belongs_to :author
  belongs_to :sender, :class_name => "Author"
  belongs_to :recipient, :class_name => "Author"
  
  default_scope :order => 'created_at'
  named_scope :unread, :conditions => {:unread => true}
end