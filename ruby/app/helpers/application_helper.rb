module ApplicationHelper
  def haiku_div_tag(haiku)
    "<div id=\"haiku-#{haiku.id}\" class=\"haiku\">"
  end
  
  def modify_favorite_div_tag(haiku)
    "<div id=\"haiku-favorite-#{haiku.id}\">"
  end
  
  def main_menu_link_to(name, controller)
    link_to_unless_current(name, {:controller => controller, :action => "index"}) do |name| 
      link_to(name, {:controller => controller, :action => "index"}, {:class => "selected"})
    end
  end
  

  # copied from http://www.igvita.com/blog/2006/09/10/faster-pagination-in-rails/
  # This leverages the pagination_find plugin
  def windowed_pagination_links(pagingEnum, options)
    link_to_current_page = options[:link_to_current_page]
    always_show_anchors = options[:always_show_anchors]
    padding = options[:window_size]

    current_page = pagingEnum.page
    html = ''

    #Calculate the window start and end pages 
    padding = padding < 0 ? 0 : padding
    first = pagingEnum.page_exists?(current_page  - padding) ? current_page - padding : 1
    last = pagingEnum.page_exists?(current_page + padding) ? current_page + padding : pagingEnum.last_page

    # Print start page if anchors are enabled
    html << yield(1) if always_show_anchors and not first == 1

    # Print window pages
    first.upto(last) do |page|
      (current_page == page && !link_to_current_page) ? html << page : html << yield(page)
    end

    # Print end page if anchors are enabled
    html << yield(pagingEnum.last_page) if always_show_anchors and not last == pagingEnum.last_page
    html
  end  
end
