# frozen_string_literal: true

Rails.application.routes.draw do
  root 'pages#home'

  resource :weather, only: [:index, :show], controller: 'weather'
  resource :recipes, only: [:index, :show], controller: 'recipes'
  resource :books, only: [:index, :show], controller: 'books'
  resource :jokes, only: [:index, :show], controller: 'jokes'

  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check
end
