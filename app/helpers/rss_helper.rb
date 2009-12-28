module RssHelper
  def rss_discovery(title, url)
    content_for :head, auto_discovery_link_tag(:atom, "#{url}.atom", {:title => title})
  end
end