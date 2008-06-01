$:.unshift(File.dirname(__FILE__))

%w(action_controller action_view active_record).each do |lib|
  require "#{lib}/init.rb"
end