module HaikuRecord
  module Inspirations
    def self.included(base)
      base.extend(InspirationalMethods)
    end
    
    module InspirationalMethods
      def inspired_by(name)
        extend ClassMethods
        include InstanceMethods
        belongs_to :conversation
        before_create :generate_conversation
      end
    end
  
    module ClassMethods
    end
    
    module InstanceMethods
      def generate_conversation
        self.conversation = Conversation.create
      end
    end
  end
end