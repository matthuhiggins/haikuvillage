module ApplicationHelper
  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag *args }
  end
  
  def javascript(*args)
    content_for(:head) { javascript_include_tag *args }
  end
  
  def link_to_controller(name, controller_name)
    html_options = controller.controller_name == controller_name ? {:class => 'selected'} : {}
    link_to(name, {:controller => controller_name}, html_options)
  end
end
