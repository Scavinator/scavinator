scope "", as: :root, controller: :root do
  root action: :index
  get "dash"
end
get 'users/me/discord', to: 'users#discord_oauth'
resources :users, only: [:new, :create]
resource :session
get 'logout', to: 'sessions#destroy', as: :logout
resources :passwords, param: :token, except: [:new]
resources :scav_hunts, path: "hunts"
