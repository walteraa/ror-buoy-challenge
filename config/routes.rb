# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :accommodations do
        member do
          post :book
        end
        resources :bookings, only: %i[index create]
      end

      resources :hotels do
        resources :rooms, controller: 'hotels/rooms'
      end

      resources :apartments

      resources :bookings, only: %i[show update destroy]
      get '/bookings', to: 'bookings#list'
    end
  end
end
