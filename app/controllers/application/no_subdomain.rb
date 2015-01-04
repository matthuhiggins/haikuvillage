module Application
  module NoSubdomain
    extend ActiveSupport::Concern

    included do
      before_filter :redirect_if_no_subdomain
    end

    private
      def redirect_if_no_subdomain
        if request.subdomains.empty?
          redirect_to 'http://www.haikuvillage.com', status: 301
        end
      end
  end
end
