module ApplicationHelper
  extend ActiveSupport::Memoizable

  def link_to_controller(name, category)
    url = send("#{category}_url")
    html_options = current_category == category ? {:class => 'selected'} : {}
    link_to(name, url, html_options)
  end
  
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
    content_for :head, auto_discovery_link_tag(:atom, url, {:title => title})
  end

  def current_category
    /^\/(\w+)/ =~ request.request_uri
    $1
  end
  memoize :current_category
end
