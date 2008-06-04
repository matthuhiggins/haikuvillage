module HaikuController
  module HaikuListing
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
  end
end