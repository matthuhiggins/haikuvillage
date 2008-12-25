module ApplicationHelper
  def link_to_controller(name, controller_name)
    html_options = controller.controller_name == controller_name ? {:class => 'selected'} : {}
    link_to(name, {:controller => controller_name}, html_options)
  end
  
  def title(title, prefix = true)
    if prefix
      title = "HaikuVillage: #{title}"
    end

    content_for :title, h(title)
  end
  
  def description(description)
    content_for(:description, tag(:meta, {:name => "description", :content => h(description)}))
  end
end
