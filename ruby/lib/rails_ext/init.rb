$:.unshift(File.dirname(__FILE__))

%w(action_controller action_view).each do |lib|
  require "#{lib}/init.rb"
end