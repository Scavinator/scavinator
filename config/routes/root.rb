scope "", as: :root, controller: :root do
  root action: :index
  get "dash"
  resources :users, only: [:new, :create]
end
resource :session
get 'logout', to: 'sessions#destroy', as: :logout
resources :passwords, param: :token, except: [:new]
resources :scav_hunts, path: "hunts"
