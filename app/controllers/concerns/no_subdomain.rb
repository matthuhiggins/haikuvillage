module Concerns
  module NoSubdomain
    extend ActiveSupport::Concern

    included do
      before_filter :redirect_if_any_subdomain
    end

    private
      def redirect_if_any_subdomain
        if request.subdomains.any?
          redirect_to 'http://haikuvillage.com'
        end
      end
  end
end