module ProfileHelper
  def sub_menu_link(name, options)
    current = current_page?(options)
    list_options = current ? {:class => "selected"} : {}
    content_tag(:li, list_options) do
      link_to_unless(current, name, options)
    end
  end
end