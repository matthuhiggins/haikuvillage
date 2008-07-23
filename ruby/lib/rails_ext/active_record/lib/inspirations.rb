module HaikuRecord
  module Inspirations
    def self.included(base)
      base.extend(InspirationalMethods)
    end
    
    module InspirationalMethods
      def inspired_by(name)
        belongs_to :conversation
        extend ClassMethods
        include InstanceMethods
      end
    end
  
    module ClassMethods
      def clense
        delete_all :conversation_id => nil
      end
    end
    
    module InstanceMethods
      
    end
  end
end