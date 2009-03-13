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
  
  def header_search_form
    form_tag({:controller => '/haikus', :action => 'search'}, {:method => :get}) do
      concat(tag(:input, {
        :type => "text", 
        :name => "q",
        :value => 'Search for haikus', 
        :autocomplete => 'off', 
        :id => 'haiku_search'
      }))
    end
  end
end