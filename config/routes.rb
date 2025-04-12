Rails.application.routes.draw do
  constraints host: "scavinator.com" do
    scope "", as: :root, controller: :root do
      root action: :index
      get "dash"
      resources :users, only: [:new, :create]
    end
    resource :session
    get 'logout', to: 'sessions#destroy', as: :logout
    resources :passwords, param: :token, except: [:new]
    resources :scav_hunts, path: "hunts"
  end
  constraints (-> (req) { m = req.host.match /([^\.]+)\.scavinator\.com/; req.path_parameters[:prefix] = m[1] if m; return m }) do
    resource :team, controller: :team, path: ""
    scope "", as: :team, controller: :team do
      resources :scav_hunts, module: :team, path: "hunts", param: :slug do
        resources :role_members, module: :scav_hunt
        resources :pages, module: :scav_hunt, param: :page_number
        resources :tags, module: :scav_hunt
        namespace :items, module: :scav_hunt do
          get 'mine', to: 'items#index_mine', as: :mine
        end
        resources :items, module: :scav_hunt do
          resources :tags, module: :item, param: :item_tag_id do
          end
          namespace :tag, module: :item do
            patch ':item_tag_id/approve', to: 'tags#approve', as: :approve
          end
          resources :users, module: :item
        end
      end
      resources :tags, module: :team
      resources :roles, module: :team
      namespace :users, module: :team do
        get 'pending', to: 'users#index_pending', as: :pending
        get 'banned', to: 'users#index_banned', as: :banned
      end
      namespace :users, module: :team do
        resources :captains, module: :users
      end
      resources :users, module: :team
      get 'login', to: 'team#new_session', as: :new_session
      post 'login', to: 'team#create_session', as: :create_session
      get 'logout', to: 'sessions#destroy', as: :logout
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
