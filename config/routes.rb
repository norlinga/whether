# frozen_string_literal: true

Rails.application.routes.draw do
  # resources :mockups, only: %i[index show] do
  #   collection do
  #     get 'choose'
  #   end
  # end

  root 'forecast#index'

  resources :forecast, only: %i[index show]

  get '/address/choose', to: 'address#choose', as: :choose_address
  post '/address/search', to: 'address#search', as: :search_address
end
