# frozen_string_literal: true

Rails.application.routes.draw do
  # Health check endpoint for Docker health checks
  get 'health', to: 'health#show'

  # API endpoints
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :jobs, only: %i[create index] do
        member do
          get :status
        end
      end
    end
  end
end
