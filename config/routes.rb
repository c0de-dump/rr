# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'products#index'

  resource :session
  resources :passwords, param: :token
  resources :products do
    resources :subscribers, only: [:create]
  end
  resource :unsubscribe, only: [:show]
end
