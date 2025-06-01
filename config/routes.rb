Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :menus, only: %i[index show]

  resources :restaurants, only: %i[index show] do
    post "import", to: "restaurants#import", on: :collection
  end

  resources :import_statuses, only: %i[show]
end
