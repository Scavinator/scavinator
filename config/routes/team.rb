resources :scav_hunts, module: :team, path: "hunts", param: :slug do
  resources :role_members, module: :scav_hunt
  resources :pages, module: :scav_hunt, param: :page_number
  resources :tags, module: :scav_hunt
  namespace :items, module: :scav_hunt do
    get 'mine', to: 'items#index_mine', as: :mine
  end
  resources :items, module: :scav_hunt, param: :number, only: [:index, :create, :new]
  resources :items, module: :scav_hunt, param: :number, only: [:show, :edit, :update, :destroy], path: "items/(:list_category_slug)" do
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
resource :user, path: "users/me", only: [:edit, :update, :show]
namespace :users, module: :team do
  get 'pending', to: 'users#index_pending', as: :pending
  get 'banned', to: 'users#index_banned', as: :banned
  resources :captains, module: :users
end
resources :users, module: :team
get 'login', to: 'team#new_session', as: :new_session
post 'login', to: 'team#create_session', as: :create_session
get 'logout', to: 'sessions#destroy', as: :logout
