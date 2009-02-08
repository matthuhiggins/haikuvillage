ActionController::Routing::Routes.draw do |map|  
  map.resource :session
  map.resources :authors, :collection => {:invite => :any, :forgot => :any, :reset_password => :any} do |author|
    author.resources :subjects, :controller => "authors/subjects"
    author.resources :friends, :controller => "authors/friends"
  end

  map.resources :subjects, :collection => {:suggest => :get}
  map.resources :haikus, :collection => {:search => :get}, :member => {:email => :get, :deliver => :post } do |haikus|
    haikus.resource :favorites
  end
  map.resources :conversations

  map.root :controller => 'public'

  map.about     'about',    :controller => 'public',    :action => "about"
  map.register  'register', :controller => "public",    :action => "register"
  map.signup    'signup',   :controller => "authors",   :action => 'new'
  map.login     'login',    :controller => 'sessions',  :action => 'new'
  map.logout    'logout',   :controller => 'sessions',  :action => 'destroy'

  map.profile   'profile',  :controller => 'profile',   :action => 'index'
  map.journal   'journal',  :controller => 'journal',   :action => 'index'
  map.forgot    'forgot',   :controller => 'authors',   :action => 'forgot'
  map.reset_password 'reset_password',   :controller => 'authors',   :action => 'reset_password'

  map.google_gadget 'google_gadget', :controller => "public", :action => "google_gadget", :format => "xml"
  map.sitemap 'sitemap', :controller => 'public', :action => "sitemap", :format => "xml"
  map.connect 'google08da94d9e67eee9b.html', :controller => 'public', :action => "about"
  map.connect 'logged_exceptions/:action/:id', :controller => 'logged_exceptions'

  map.connect ':controller/:action/:id'  
  map.connect ':controller/:action/:id.:format'
end
