ActionController::Routing::Routes.draw do |map|  
  # home page
  map.connect '', :controller => "welcome", :action => "index"
  map.resource :session
  
  # the sick syllable counter
  map.syllables "syllables/:word.:format", :word => %r{.+}, :controller => "syllables", :action => "count"

  map.login 'login/', :controller => "login", :action => "index"
  map.logout 'logout/', :controller => "login", :action => "logout"
    
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end