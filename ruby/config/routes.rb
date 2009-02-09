ActionController::Routing::Routes.draw do |map|  
  map.resources :authors,
                :member => {:friends => :get},
                :collection => {:invite => :any, :forgot => :any, :reset_password => :any} do |author|
    author.resources :subjects, :controller => "authors/subjects"
  end

  map.resources :subjects, :collection => {:suggest => :get}
  map.resources :haikus, :collection => {:search => :get}, :member => {:email => :get, :deliver => :post }
  map.resources :conversations
  map.resources :messages
  map.resources :friends
  map.resources :favorites
  map.resource :session

  map.root :controller => 'public'

  map.about     'about',    :controller => 'public',    :action => "about"
  map.register  'register', :controller => "public",    :action => "register"
  map.login     'login',    :controller => 'sessions',  :action => 'new'
  map.logout    'logout',   :controller => 'sessions',  :action => 'destroy'
  map.signup    'signup',   :controller => "authors",   :action => 'new'
  map.forgot    'forgot',   :controller => 'authors',   :action => 'forgot'
  map.reset_password 'reset_password',   :controller => 'authors',   :action => 'reset_password'
  map.profile   'profile',  :controller => 'profile',   :action => 'index'
  map.journal   'journal',  :controller => 'journal',   :action => 'index'

  map.google_gadget 'google_gadget', :controller => "public", :action => "google_gadget", :format => "xml"
  map.sitemap 'sitemap', :controller => 'public', :action => "sitemap", :format => "xml"
  map.connect 'google08da94d9e67eee9b.html', :controller => 'public', :action => "about"
  map.connect 'logged_exceptions/:action/:id', :controller => 'logged_exceptions'

  map.connect ':controller/:action/:id'  
  map.connect ':controller/:action/:id.:format'
end
