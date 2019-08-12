Rails.application.routes.draw do
  root 'home#index'

  resources :users, except: [:index] do
    resources :posts do
      resources :comments
    end
  end
  resources :sessions, only: [:create]

  get 'search', to: 'users#search', as: 'search'
  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
