Rails.application.routes.draw do
  root to: 'pages#home'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/search', to: 'pages#search'
  get '/trello', to: 'pages#trello'
  get '/weather', to: 'pages#weather'
  get '/youtube', to: 'pages#youtube'
  get '/food', to: 'pages#food'
end
