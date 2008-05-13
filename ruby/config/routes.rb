ActionController::Routing::Routes.draw do |map|  
  # home page
  map.root :controller => "welcome", :action => "index"
  
  map.resource :session
  map.resources :users, :member => { :favorites => :get }
  
  map.resources :haikus, :collection => {:popular => :get}, :requirements => {:id => /.*/} do |haikus|
    haikus.resource :favorites
  end
    
  # the sick syllable counter
  map.syllables "syllables/:word.:format", :word => %r{.+}, :controller => "syllables", :action => "count"

  map.login 'login/', :controller => "session", :action => "create"
  map.logout 'logout/', :controller => "session", :action => "destroy"
  map.create 'create', :controller => 'haikus', :action => "new"
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end