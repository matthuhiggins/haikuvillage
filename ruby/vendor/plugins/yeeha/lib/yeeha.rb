require 'set'
module Higgode
  module Yeeha #:nodoc
    @@aggregate = Set.new(['yahoo-dom-event', 'utilities', 'reset-fonts-grids'])
    @@beta = Set.new(['button', 'element', 'datasource', 'datasource'])
    @@css = Set.new(['reset', 'base', 'fonts', 'grids', 'reset-fonts-grids'])
    @@control = Set.new(['container', 'menu', 'autocomplete', 'button', 'calendar', 'colorpicker', 'datatable', 'tabview', 'treeview'])
    
    def yui_component_tag(source)
      file_name = @@beta.include?(source) ? "#{source}-beta" : source      
      file_name = "#{file_name}-min" unless  @@aggregate.include?(source)
      if @@css.include?(source)
        stylesheet_link_tag("#{yui_root}/#{source}/#{file_name}")
      elsif @@control.include?(source)
        [stylesheet_link_tag("#{yui_root}/#{source}/assets/skins/sam/#{source}"),
            javascript_include_tag("#{yui_root}/#{source}/#{file_name}")].join("\n")       
      else
        javascript_include_tag("#{yui_root}/#{source}/#{file_name}")
      end
    end
  
    def yui_include_tag(*sources)
      sources.map { |source| yui_component_tag(source) }.join("\n")
    end
    
    def yui_root
      #"http://yui.yahooapis.com/2.3.0/build"
      "/yui"
    end
  end
end