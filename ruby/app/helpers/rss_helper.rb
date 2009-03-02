module RssHelper
  def rss_discovery(title, url)
    content_for :head, auto_discovery_link_tag(:atom, "#{url}.atom", {:title => title})
  end
  
  # Options are
  #   :title
  #
  def render_atom(haikus, options = {})
    @haikus = haikus
    @title = options[:title] || 'Haiku'
    render :template => "rss/haikus", :format => :atom
  end
end