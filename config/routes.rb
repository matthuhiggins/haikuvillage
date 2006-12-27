ActionController::Routing::Routes.draw do |map|
  map.resources :schools
  
  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "welcome"
  
  map.syllables "syllables/:word;json", :controller => "syllables", :action => "count_json"
  map.syllables "syllables/:word", :controller => "syllables", :action => "count"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # login/logout/register
  map.login 'login/', :controller => "login", :action => "index"
  map.logout 'logout/', :controller => "login", :action => "logout"
  map.register 'register/', :controller => "login", :action => "register"
    
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
