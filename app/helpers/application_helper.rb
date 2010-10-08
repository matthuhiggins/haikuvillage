module ApplicationHelper
  extend ActiveSupport::Memoizable
  
  def title(title)
    title = "Haiku Village: #{title}"
    content_for :title, title
  end
  
  def description(description)
    full_description = "#{h(description)}"
    content_for(:description, tag(:meta, {:name => "description", :content => full_description}))
  end
  
  def current_category
    /^\/(\w+)/ =~ request.request_uri
    $1
  end
  memoize :current_category
end
