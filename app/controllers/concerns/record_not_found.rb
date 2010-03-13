module Concerns
  module RecordNotFound
    def self.included(controller)
      controller.class_eval do
        rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
      end
    end
    
    private
      def record_not_found
        render :action => '404'
      end
  end
end