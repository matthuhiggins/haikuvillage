module SearchHelper
  def search_form(url)
    html = form_tag(url, {:method => :get})
    html << text_field_tag("q", params[:q])
    html << submit_tag("Search")
    html << "</form>"
    [html, field_focus].join
  end
  
  def field_focus
    content_tag(:script, "$('q').focus()")
  end
end