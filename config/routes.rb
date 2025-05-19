# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  resource :session
  resources :passwords, param: :token
  resources :products
end
