HaikuVillage::Application.routes.draw do
  # reset password!
  resources :authors do
    member do
      get :friends
    end

    resources :subjects, :controller => 'authors/subjects'
  end

  resources :subjects do
    collection do
      get :suggest
    end
  end

  resources :haikus, :path => 'haiku' do
    collection do
      get :search
    end
  end

  resources :conversations
  resources :messages
  resources :friends
  resources :favorites
  resources :registrations, :as => 'signup'

  resource :session

  root :to => 'public#index'

  controller 'public' do
    match 'about' => :about, :as => :about
    match 'register' => :register, :as => :register
    match 'feedback' => :feedback, :as => :feedback
  end

  controller 'sessions' do
    match 'login' => :new, :as => 'login'
    match 'logout' => :destroy, :as => 'logout'
  end

  
  match   'profile(/:action)' => 'profile', :as => :profile
  match   'journal(/:action)' => 'journal', :as => :journal


  match 'google_gadget' => 'public#google_gadget', :defaults => { :format => 'xml' }, :as => 'google_gadget'
  match 'sitemap' => 'public#sitemap', :defaults => { :format => 'xml' }, :as => 'sitemap'

  # match ''
end
