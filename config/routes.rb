Rails.application.routes.draw do
  root "pages#home"

  resources :weather, only: [:index, :create]
  resources :recipes, only: [:index, :create]
  resources :books, only: [:index, :create]
  resources :jokes, only: [:index, :create]
  resources :numbers, only: [:index, :create]
  resources :trivia, only: [:index, :create]
  post "/trivia/check", to: "trivia#check", as: :check_trivia
  resources :youtube, only: [:index, :create]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
