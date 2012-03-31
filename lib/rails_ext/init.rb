$:.unshift(File.dirname(__FILE__))

%w(active_support active_record).each do |lib|
  require "#{lib}/init.rb"
end