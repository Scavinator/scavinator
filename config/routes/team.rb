resources :scav_hunts, module: :team, path: "hunts", param: :slug do
  resource :discord, module: :scav_hunt, controller: :discord, only: [:edit, :update]
  resources :role_members, module: :scav_hunt
  resources :roles, module: :scav_hunt
  resources :pages, module: :scav_hunt, param: :page_number
  get 'category/:category_slug', to: "scav_hunt/items#by_category", as: :category
  resources :tags, module: :scav_hunt
  namespace :items, module: :scav_hunt do
    get 'mine', to: 'items#index_mine', as: :mine
    get 'wizard', to: 'items#item_wizard_page'
  end
  resources :items, module: :scav_hunt, param: :number, only: [:index, :create, :new]
  resources :items, module: :scav_hunt, param: :number, only: [:show, :edit, :update, :destroy], path: "items/(:list_category_slug)" do
    resources :tags, module: :item, param: :item_tag_id do
    end
    namespace :tag, module: :item do
      patch ':item_tag_id/approve', to: 'tags#approve', as: :approve
    end
    resources :users, module: :item
    resources :files, module: :item
    resource :submission, controller: :submission, module: :item
    namespace :file, as: 'submission_file', path: 'submission/file', controller: :submission, module: :item do
      post '', action: :attach_file, as: :attach
      delete ':id', action: :detach_file, as: :detach
    end
  end
end
resources :tags, module: :team
resources :roles, module: :team
namespace :users, module: :team do
  get 'pending', to: 'users#index_pending', as: :pending
  get 'banned', to: 'users#index_banned', as: :banned
  resources :captains, module: :users
end
resources :users, module: :team do
  member do
    patch 'manage', to: 'users#manage', as: :manage
  end
end
namespace :authcode, controller: :authcodes do
  post "from_current", to: "authcodes#create_from_path"
end
resources :authcodes, module: :team do
end
get 'settings'
get 'login', to: 'team#new_session', as: :new_session
post 'login', to: 'team#create_session', as: :create_session
get 'logout', to: 'sessions#destroy', as: :logout
