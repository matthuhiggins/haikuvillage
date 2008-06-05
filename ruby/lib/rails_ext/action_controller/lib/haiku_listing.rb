module HaikuController
  module HaikuListing
    def self.included(base)
      base.send(:helper_method, :haiku_sort_param)
    end
    
    private
    # Lists out haikus with pagination.
    # * <tt>:cached_total</tt> -- Total number of entries for the current search. For performance reasons, we never want to count from the database
    #   In the case that :cached_total is not provided, only Next and Previous links are provided
    # * <tt>:title</tt> -- The header to display above the list. If not provided, method is humanized.
    # * <tt>:order_scope</tt> -- A custom order scope to override the default
    # Sets @haikus, @title and @page_links
    def list_haikus(source, options = {})
      cached_total = options.delete(:cached_total) || 0
      
      options.merge!(:page          => params[:page],
                     :per_page      => HaikuEnv.haikus_per_page,
                     :total_entries => cached_total,
                     :include       => :author)

      @title = options.delete(:title) || 'Haikus'
      @haikus = source.send(haiku_sort_param).paginate(options)

      if cached_total == 0
        @haikus.total_entries = @haikus.offset + [@haikus.length, HaikuEnv.haikus_per_page].min + 1
        @page_links = false
      else
        @page_links = true
      end
      
      respond_to do |f|
        f.html render :template => "templates/listing"
        f.atom
      end
    end
        
    VALID_SORT_SCOPES = [:recent, :most_viewed, :top_favorites].to_set
    
    def haiku_sort_param
      if params[:order].nil?
        :recent
      else
        order_name = params[:order].to_sym
        VALID_SORT_SCOPES.include?(order_name) ? order_name : :recent
      end
    end
  end
end