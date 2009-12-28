$:.unshift(File.dirname(__FILE__))

%w(active_support action_controller active_record).each do |lib|
  require "#{lib}/init.rb"
end