Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Home - landing page
  root "home#index"

  # Links
  resource :links, only: [:new, :create]
  get '/links/:short_code', to: 'links#show', as: :short_code_links
  get '/links/:short_code/destroy', to: 'links#destroy', as: :destroy_links
  get '/qr', to: 'qrcodes#download', as: :download_qr_codes

  # users
  resource :users, only: [:new, :create]
  get '/users/dashboard', to: 'users#dashboard', as: :users_dashboard
  get '/login', to: 'sessions#new', as: :user_login_form
  post '/login', to: 'sessions#create', as: :user_login
  get '/logout', to: 'sessions#destroy', as: :user_logout

  # this redirect
  get ':short_code', to: 'links#redirect', as: :redirect_short_code_links
end
