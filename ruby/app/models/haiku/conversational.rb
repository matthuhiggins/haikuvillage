module Conversational
  def self.included(base)
    base.class_eval do
      belongs_to :conversation

      attr_accessor :conversing_with
      before_create :construct_conversation
      
      after_create do |haiku|
        haiku.conversation.update_attributes(:latest_haiku_update => Time.now) unless haiku.conversation_id.nil?
        Conversation.update_counters(haiku.conversation_id, :haikus_count_week => 1, :haikus_count_total => 1) if haiku.conversation_id
      end
      
      before_destroy do |haiku|
        Conversation.update_counters(haiku.conversation_id, :haikus_count_total => -1) if haiku.conversation_id
      end
    end
  end
  
  def conversing?
    !conversation.nil? && conversation.haikus_count_total > 0
  end
  
  private
    def construct_conversation
      unless conversing_with.nil? || conversing_with.empty?
        other_haiku = Haiku.find(conversing_with)
        connect_with(other_haiku)
        HaikuMailer.deliver_conversation_notice(other_haiku, self.author)
      end
    rescue ActiveRecord::RecordNotFound
      # In case the other haiku was deleted while someone was responding to it
    end
  
    def connect_with(other_haiku)
      if other_haiku.conversation.nil?
        other_haiku.create_conversation(:haikus_count_total => 1)
        other_haiku.save!
      end
      self.conversation = other_haiku.conversation
    end
end