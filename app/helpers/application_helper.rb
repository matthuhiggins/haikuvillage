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

  def menu_item(selected, &block)
    html_options = selected ? {class: 'selected'} : {}
    content_tag :li, html_options, &block
  end
end
