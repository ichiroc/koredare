Rails.application.routes.draw do
  resources :photos, only: [:new, :create]
  resource :session, only: [:new, :create]
  resources :quizzes, only: [:index, :show] do
    resource :answer, only: [:show]
  end

  root "photos#new"

  get "up" => "rails/health#show", as: :rails_health_check
end
