module HaikusHelper

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