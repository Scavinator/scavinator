Rails.application.routes.draw do
  constraints host: Rails.configuration.scavinator_domain do
    draw(:root)
  end
  constraints (-> (req) { m = req.host.match /^([^\.]+)\.#{Regexp.quote Rails.configuration.scavinator_domain}/; req.path_parameters[:prefix] = m[1] if m; return m }) do
    resource :team, controller: :team, path: ""
    scope "", as: :team, controller: :team do
      draw(:team)
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
