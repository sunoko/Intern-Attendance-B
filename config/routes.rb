Rails.application.routes.draw do
  get 'users/new'

  root                      'static_pages#home'
  get    'help'          => 'static_pages#help'
  get    'link'          => 'static_pages#link'
  get    'about'         => 'static_pages#about'
  get    'contact'       => 'static_pages#contact'
  get    'signup'        => 'users#new'
  get    'login'         => 'sessions#new'
  post   'login'         => 'sessions#create'
  delete 'logout'        => 'sessions#destroy'
  get    'attend_edit'   => 'users#attend_edit'
  patch  'attend_edit'   => 'users#attend_update'
  get    'work'          => 'users#work'
  get    'basic_info'    => 'users#basic_info'
  patch  'ba_info_edit'  => 'users#ba_info_edit'
  
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
end