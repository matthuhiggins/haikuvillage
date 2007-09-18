module HaikusHelper
  def highlight_search(search_terms)
    content_tag('script') do
      "Village.util.registerWithHaikuRefresh(function() { " +
      "   Village.Search.highlight('#{params[:q]}');" +
      "});"
    end
  end
end