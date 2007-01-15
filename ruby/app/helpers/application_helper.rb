module ApplicationHelper
  def haiku_div_tag(haiku)
    "<div id=\"haiku-#{haiku.id}\" class=\"haiku\">"
  end
  
  def modify_favorite_div_tag(haiku)
    "<div id=\"haiku-favorite-#{haiku.id}\">"
  end
  
  def get_tag_span(tagcount, attributes = {})
    if tagcount.to_i == 1 then
      attributes["class"] = "1"
    else
      attributes["class"] = "2"      
    end
    attrs = tag_options(attributes.stringify_keys)
    "<span #{attrs}>"
  end
  
  def render_list_items(items, controller)
    result = ""
    items.each do |action|
      result << "<li>#{link_to(action.capitalize, {:controller => controller, :action => action})}</li>"
    end
    result
  end  
end
