module Concerns
  module DeferredHaiku
    extend ActiveSupport::Concern

    included do
      helper_method :deferred_haiku
    end

    def deferred_haiku
      if session[:deferred_haiku]
        @deferred_haiku ||= Haiku.new(session[:deferred_haiku])
      end
    end
  end
end