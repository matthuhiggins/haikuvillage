class ApplicationController < ActionController::Base
  # Raised when a destroy action is performed on an object
  # not owned by current_author
  class UnauthorizedDestroyRequest < StandardError
  end
  
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  
  helper :favorites, :haikus
  
  before_filter :basic_auth
      
  private
    # Lists out haikus with pagination.
    # * <tt>:cached_total</tt> -- Total number of entries for the current search. For performance reasons, we never want to count from the database
    #   In the case that :cached_total is not provided, only Next and Previous links are provided
    # * <tt>:title</tt> -- The header to display above the list. If not provided, method is humanized.
    #
    # Sets @haikus, @title and @page_links
    def list_haikus(source, method, options = {})
      cached_total = options[:cached_total].nil? ? 0 : source.send(options.delete(:cached_total))
      
      options.merge!(:page          => params[:page],
                     :per_page      => HaikuEnv.haikus_per_page,
                     :total_entries => cached_total,
                     :include       => :author)

      @title = options.delete(:title) || method.to_s.humanize
      @haikus = source.send(method).paginate(options)

      if cached_total == 0
        @haikus.total_entries = @haikus.offset + [@haikus.length, HaikuEnv.haikus_per_page].min + 1
        @page_links = false
      else
        @page_links = true
      end

      render :template => "templates/listing"
    end
    
    def input_haiku(proxy, options = {})
      options.merge!(:limit => 4, :include => :author)
      @haikus = proxy.all(options)
      render :template => "templates/input"
    end

    def referring_uri
      params[:referrer] || request.env["HTTP_REFERER"] || root_url
    end

    def current_author
      @current_author ||= Author.first(:conditions => {:username => session[:username]}, :include => :favorites) unless session[:username].nil?
    end
    
    helper_method :referring_uri, :current_author
    
    def basic_auth
      return if local_request?
      
      authenticate_or_request_with_http_basic do |user_name, password| 
        user_name == 'haiku' && password == '575'
      end
    end
end