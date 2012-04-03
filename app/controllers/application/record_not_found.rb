module Application
  module RecordNotFound
    extend ActiveSupport::Concern

    included do
      rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
    end
    
    private
      def record_not_found(exception)
        if exception.message =~ /^Couldn't find (.*) with/
          render :template => "/404/#{$1.downcase}"
        end
      end
  end
end