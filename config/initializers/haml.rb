require 'haml'

# Load Haml and Sass
Haml.init_rails(binding)

Haml::Template.options[:attr_wrapper] = '"'

Sass::Plugin.options[:always_update] = true
Sass::Plugin.options[:style] = :expanded