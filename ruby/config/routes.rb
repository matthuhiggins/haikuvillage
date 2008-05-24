ActionController::Routing::Routes.draw do |map|  
  # home page
  map.root :controller => "welcome", :action => "index"
  
  map.resource :session
  map.resources :authors, :member => { :favorites => :get }
  
  map.resources :haikus, :collection => {:top_favorites => :get, :most_viewed => :get}, :requirements => {:id => /.*/} do |haikus|
    haikus.resource :favorites
  end
    
  map.login 'login/', :controller => "session", :action => "create"
  map.logout 'logout/', :controller => "session", :action => "destroy"
  map.create 'create', :controller => 'haikus', :action => "new"
  
  map.connect "logged_exceptions/:action/:id", :controller => "logged_exceptions"
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end