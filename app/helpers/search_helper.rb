module SearchHelper
  def header_search_form
    form_tag({:controller => '/haikus', :action => 'search'}, {:method => :get}) do
      concat(tag(:input, {
        :type => "text", 
        :name => "q",
        :value => 'Search for haiku', 
        :autocomplete => 'off', 
        :id => 'haiku_search',
        class: 'empty'
      }))
    end
  end
end