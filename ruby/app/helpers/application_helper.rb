module ApplicationHelper  
  def main_menu_link_to(name, controller)
    uri = @controller.request.request_uri.gsub(/^\//, '').split(/\//).first
    link_to_unless(uri == controller, name, {:controller => controller, :action => "index"}) do |name| 
      link_to(name, {:controller => controller, :action => "index"}, {:class => "selected"})
    end
  end

  # copied from http://www.igvita.com/blog/2006/09/10/faster-pagination-in-rails/
  # This leverages the pagination_find plugin
  def windowed_pagination_links(pagingEnum, options)
    link_to_current_page = options[:link_to_current_page]
    padding = options[:window_size]

    current_page = pagingEnum.page

    #Calculate the window start and end pages 
    padding = padding < 0 ? 0 : padding
    first = pagingEnum.page_exists?(current_page  - padding) ? current_page - padding : 1
    last = pagingEnum.page_exists?(current_page + padding) ? current_page + padding : pagingEnum.last_page

    html = ''
    # Print window pages
    first.upto(last) do |page|
      html << ((current_page == page && !link_to_current_page) ? page : yield(page))
    end

    html
  end
  
  def link_to_adjacent_page(text, page)
    link_to_remote text,
        :url => { :page => page },
        :before => "this.parentNode.innerHTML = getEl('pagination_loader').innerHTML",
        :complete => "Village.util.paginate(request, false)"
  end
end
