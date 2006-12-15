#import 'vendor/lingua'
module HaikusHelper 
  def haiku_div_tag(haiku)
    "<div id=\"haiku-#{haiku.id}\" class=\"haiku\">"
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
end