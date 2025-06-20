# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'jobs#index'

  # Health check endpoint for Docker health checks
  get 'health', to: 'health#show'

  # Job management endpoints
  resources :jobs, only: %i[create index] do
    member do
      get :status
    end
  end
end
