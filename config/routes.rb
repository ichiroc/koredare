Rails.application.routes.draw do
  resources :photos, only: [:new, :create]

  root "photos#new"

  get "up" => "rails/health#show", as: :rails_health_check
end
