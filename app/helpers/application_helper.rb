module ApplicationHelper
  def title(title)
    title = "Haiku Village: #{title}"
    content_for :title, title
  end

  def body(&block)
    html_options = {id: controller_id, class: action_name}
    content_tag(:body, html_options, &block)
  end

  def controller_id
    controller.class.name.gsub(/Controller/, '').split('::').map(&:underscore) * '_'
  end

  def description(description)
    content_for(:description, tag(:meta, {name: "description", content: description}))
  end

  def menu_item(selected, &block)
    html_options = selected ? {class: 'selected'} : {}
    content_tag :li, html_options, &block
  end
end
