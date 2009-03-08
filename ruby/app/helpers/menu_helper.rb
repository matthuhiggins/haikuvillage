module MenuHelper
  # Use like so:
  #   <% sub_menu do |m| %>
  #     <% m.link "Account", :action => 'index' %>
  #     <% m.link "Password", :action => 'password' %>
  #     <% m.link "Avatar", :action => 'avatar' %>
  #   <% end %>
  #
  def sub_menu(options, &block)
    concat(tag(:ul, {:class => options[:class]}, true))
    linker = SubMenuLinker.new(self)
    yield(linker)
    concat(linker.generate)
    concat("</ul>")
  end
  
  class SubMenuLinker
    def initialize(template)
      @template = template
      @links = []
    end

    def link(name, options)
      current = current_page?(options)
      list_options = current ? {:class => "selected"} : {}
      @links << content_tag(:li, list_options) do
        link_to_unless(current, name, options)
      end
    end
    
    def generate
      @links.join("\n")
    end
    
    def method_missing(method, *args, &block)
      @template.send(method, *args, &block)
    end
  end
end