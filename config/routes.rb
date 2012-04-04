HaikuVillage::Application.routes.draw do
  resources :authors do
    member do
      get :friends
    end

    resources :subjects, controller: 'authors/subjects'
  end
  match 'signup' => 'authors#new', as: 'signup'

  match 'autocomplete/subject' => 'subjects#autocomplete'

  resources :subjects do
    collection do
      get :suggest
    end
  end

  resources :haikus, path: 'haiku' do
    collection do
      get :search
    end
  end

  resources :conversations
  resources :messages
  resources :friends
  resources :favorites

  resources :password_resets, path: 'forgot'

  controller 'public' do
    match 'about' => :about, as: :about
    match 'register' => :register, as: :register
    match 'feedback' => :feedback, as: :feedback
  end

  resource :session

  controller 'sessions' do
    match 'login' => :new, as: 'login'
    match 'logout' => :destroy, as: 'logout'
  end

  match   'settings(/:action)' => 'profile', as: :profile
  match   'journal(/:action)' => 'journal', as: :journal

  match 'google_gadget' => 'public#google_gadget', defaults: { format: 'xml' }, as: 'google_gadget'
  match 'syllables' => 'syllables#index'

  root to: 'public#index'
end