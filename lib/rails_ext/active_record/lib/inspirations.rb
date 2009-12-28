module HaikuRecord
  module Inspirations
    def self.included(base)
      base.extend(InspirationalMethods)
    end
    
    module InspirationalMethods
      def inspired_by(name)
        extend ClassMethods
        include InstanceMethods

        cattr_accessor :inspiration_type
        self.inspiration_type = name.to_s

        belongs_to :conversation
        before_create :generate_conversation
      end
    end
  
    module ClassMethods
    end
    
    module InstanceMethods      
      def generate_conversation
        self.conversation = Conversation.create(:inspiration_type => self.class.inspiration_type)
      end
    end
  end
end