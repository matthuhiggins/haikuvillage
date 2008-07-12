module ApplicationHelper
  def link_to_controller(name, controller_name)
    html_options = controller.controller_name == controller_name ? {:class => 'selected'} : {}
    link_to(name, {:controller => controller_name}, html_options)
  end
  
  def title(title)
    content_for :title, title
  end
end
