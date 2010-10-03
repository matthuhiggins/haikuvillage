module Concerns
  module RecordNotFound
    def self.included(controller)
      controller.class_eval do
        rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
      end
    end
    
    private
      def record_not_found(exception)
        if exception.message =~ /^Couldn't find (.*) with/
          render :template => "/404/#{$1.downcase}"
        end
      end
  end
end