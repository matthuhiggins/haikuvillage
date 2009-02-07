module ApplicationHelper
  extend ActiveSupport::Memoizable
  
  def title(title, prefix = true)
    if prefix
      title = "HaikuVillage: #{title}"
    end

    content_for :title, h(title)
  end
  
  def description(description)
    full_description = "#{h(description)}"
    content_for(:description, tag(:meta, {:name => "description", :content => full_description}))
  end
  
  def rss(title, url)
    content_for :head, auto_discovery_link_tag(:atom, "#{url}.atom", {:title => title})
  end

  def current_category
    /^\/(\w+)/ =~ request.request_uri
    $1
  end
  memoize :current_category
end
