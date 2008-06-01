ActionController::Routing::Routes.draw do |map|  
  map.resource :session
  map.resources :authors, :member => { :favorites => :get }
  map.resources :subjects
  map.resources :haikus, :collection => {:top_favorites => :get, :most_viewed => :get} do |haikus|
    haikus.resource :favorites
  end
  
  map.root :controller => 'public'
  map.about 'about',    :controller => 'public',  :action => "about"
  map.login 'login',    :controller => 'session', :action => 'create'
  map.logout 'logout',  :controller => 'session', :action => 'destroy'
  map.create 'create',  :controller => 'haikus',  :action => 'new'
  
  map.connect 'logged_exceptions/:action/:id', :controller => 'logged_exceptions'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end