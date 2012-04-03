module Application
  module DeferredHaiku
    extend ActiveSupport::Concern

    included do
      helper_method :deferred_haiku
      before_filter :create_deferred_haiku, if: [:deferred_haiku, :current_author]
    end

    def save_deferred_haiku(haiku_params)
      session[:deferred_haiku] = haiku_params
    end

    def deferred_haiku
      if session[:deferred_haiku]
        @deferred_haiku ||= Haiku.new(session[:deferred_haiku])
      end
    end

    def create_deferred_haiku
      if deferred_haiku
        current_author.haikus << deferred_haiku
        session[:deferred_haiku] = nil
      end
    end
  end
end