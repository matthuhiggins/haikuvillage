require 'set'
module Higgode
  module Yeeha #:nodoc:
    def build_requirements(libraries)
      libraries.inject(SortedSet.new(libraries)) do |requirements, library|
        requirements.merge(@@dependencies[library])
      end.to_a
    end
    
    def yui_component_tag(source)
      if ["yahoo-dom-event", "utilities"].include?(source)
        file_name = "#{source}"
      elsif ["button", "element"].include?(source)
        file_name = "#{source}-beta-min"
      else
        file_name = "#{source}-min"
      end
  
      if ["reset", "fonts"].include?(source)
        stylesheet_link_tag("http://yui.yahooapis.com/2.3.0/build/#{source}/#{source}")
      else    
        javascript_include_tag("http://yui.yahooapis.com/2.3.0/build/#{source}/#{file_name}")
      end
    end
  
    def yui_include_tag(*sources)
      tags = [yui_component_tag('utilities')]
      sources.each do |source|
        tags << stylesheet_link_tag("/yui/#{source}/assets/#{source}") if defined?(RAILS_ROOT) && 
            File.exists?("#{RAILS_ROOT}/public/yui/#{source}/assets/#{source}.css")
        tags << yui_component_tag(source)
      end
      tags.join("\n")
    end
  end
end