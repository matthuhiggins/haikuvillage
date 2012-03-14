module ApplicationHelper
  def title(title)
    title = "Haiku Village: #{title}"
    content_for :title, title
  end
  
  def description(description)
    content_for(:description, tag(:meta, {name: "description", content: description}))
  end

  def menu_item(selected, &block)
    html_options = selected ? {class: 'selected'} : {}
    content_tag :li, html_options, &block
  end
end
