module ApplicationHelper  
  # This leverages the pagination_find plugin
  def windowed_pagination_links(pagingEnum)
    padding = 2

    #Calculate the window start and end page
    first = [1, [pagingEnum.page - padding, pagingEnum.last_page - padding * 2].min].max
    last = [pagingEnum.last_page, [pagingEnum.page + padding, 1 + padding * 2].max ].min

    (first..last).inject('') {|html, page| html << yield(page)}
  end
  
  def link_to_page(page)
    params_with_page = params
    params_with_page[:page] = page
    link_to_remote page, :url => params_with_page, :success => "$('paginated_haikus').innerHTML = request.responseText;Village.util.notifyHaikuObservers()"
  end
  
  def link_to_adjacent_page(text, collection, adjacency)
    adjacent_page = collection.send("#{adjacency}_page")
    if adjacent_page
      params_with_page = params
      params_with_page[:page] = collection.send("#{adjacency}_page")
      link_to_remote text,
          :url => params_with_page,
          :before => "this.parentNode.innerHTML = $('pagination_loader').innerHTML",
          :complete => "Village.util.paginate(request, '#{adjacency}')"
    else
      text
    end
  end
end
