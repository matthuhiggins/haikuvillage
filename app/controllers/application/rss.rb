module Concerns::Rss
  # Options are
  #   :title
  #
  def render_atom(haikus, options = {})
    @haikus = haikus
    @title = options[:title] || 'Haiku'
    render :template => "rss/haikus", :format => :atom
  end
end