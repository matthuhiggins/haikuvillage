ActionController::Routing::Routes.draw do |map|  
  map.resource :session
  map.resources :authors, :member => { :favorites => :get }, :collection => {:suggest => :get}
  map.resources :subjects, :collection => {:suggest => :get}
  map.resources :haikus do |haikus|
    haikus.resource :favorites
  end

  map.resources :inspirations, :collection => {:random => :get}

  map.root :controller => 'public'
  map.about 'about',    :controller => 'public',  :action => "about"
  map.sitemap 'sitemap', :controller => 'public', :action => "sitemap", :format => "xml"
  map.register 'register', :controller => "public", :action => "register"
  map.google_gadget 'google_gadget', :controller => "public", :action => "google_gadget", :format => "xml"
  
  map.login 'login',    :controller => 'session', :action => 'create'
  map.logout 'logout',  :controller => 'session', :action => 'destroy'
  
  map.connect 'google08da94d9e67eee9b.html', :controller => 'public', :action => "about"
  map.connect 'logged_exceptions/:action/:id', :controller => 'logged_exceptions'
  map.connect ':controller/:action/:id'
end
