require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?

  root "pages#home"

  resources :weather, only: [:index, :create]
  resources :recipes, only: [:index, :create]
  resources :books, only: [:index, :create]
  resources :jokes, only: [:index, :create]
  resources :numbers, only: [:index, :create]
  post "/numbers/surprise", to: "numbers#surprise", as: :surprise_numbers
  resources :trivia, only: [:index, :create]
  post "/trivia/check", to: "trivia#check", as: :check_trivia
  resources :youtube, only: [:index, :create]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
