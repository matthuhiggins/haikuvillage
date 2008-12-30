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
    full_description = "#{h(description)} on Haiku Village}"
    content_for(:description, tag(:meta, {:name => "description", :content => full_description}))
  end
  
  def rss(title)
    content_for :head, auto_discovery_link_tag(:atom, {:format =>"atom"}, {:title => title})
  end

end
