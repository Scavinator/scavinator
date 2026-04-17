scope "", as: :root, controller: :root do
  root action: :index
  get "dash"
end
get 'users/me/discord', to: 'users#link_discord', as: :link_discord
resources :users, only: [:new, :create, :edit, :update]
resource :session do
  get 'new/discord', to: 'create_discord'
end
get 'logout', to: 'sessions#destroy', as: :logout
resources :passwords, param: :token, except: [:new]
resources :scav_hunts, param: :scav_hunt_slug, path: "hunts"
