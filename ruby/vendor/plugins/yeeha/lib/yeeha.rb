module Higgode
  module Yeeha #:nodoc:
    def yui_component_tag(source)
      if ["yahoo-dom-event"].include?(source)
        file_name = "#{source}"
      elsif ["button", "element"].include?(source)
        file_name = "#{source}-beta-min"
      else
        file_name = "#{source}-min"
      end
  
      if ["reset", "fonts"].include?(source)
        stylesheet_link_tag("/yui/#{source}/#{source}")
      else    
        javascript_include_tag("/yui/#{source}/#{file_name}")
      end
    end
  
    def yui_include_tag(*sources)
      tags = []
      sources.each do |source|
        tags << stylesheet_link_tag("/yui/#{source}/assets/#{source}") if defined?(RAILS_ROOT) && 
            File.exists?("#{RAILS_ROOT}/public/yui/#{source}/assets/#{source}.css")
        tags << yui_component_tag(source)
      end
      tags.join("\n")
    end
  end
end