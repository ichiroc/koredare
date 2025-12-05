Rails.application.routes.draw do
  resources :photos, only: [:new, :create]
  resource :session, only: [:new, :create]
  resources :quizzes, only: [:index, :show] do
    resource :answer, only: [:show]
    collection do
      get :complete
    end
  end
  resource :quiz_reset, only: [:create]

  namespace :admins do
    resource :session, only: [:new, :create]
    resources :photos, only: [:index]
    root to: "photos#index"
  end

  root "photos#new"

  get "up" => "rails/health#show", as: :rails_health_check
end
