module MenuHelper
  # Use like so:
  #   <%= sub_menu do |m| %>
  #     <%= m.link "Account", :action => 'index' %>
  #     <%= m.link "Password", :action => 'password' %>
  #     <%= m.link "Avatar", :action => 'avatar' %>
  #   <% end %>
  #
  def sub_menu(options, &block)
    items = SubMenuItems.new(self)
    item_html = capture(items, &block)

    content_tag :ul, item_html.html_safe, class: options[:class]
  end
  
  class SubMenuItems
    def initialize(template)
      @template = template
    end

    def link(name, options)
      current = current_page?(options)
      link_tag = link_to_unless(current, name, options)
      list_options = current ? {:class => "selected"} : {}
      content_tag(:li, link_tag, list_options)
    end
    
    def method_missing(method, *args, &block)
      @template.send(method, *args, &block)
    end
  end
end