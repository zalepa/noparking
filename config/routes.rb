Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[new create]
  resource :profile, only: %i[edit update]
  resources :passwords, param: :token

  resources :issues, only: %i[index new create]
  resources :notifications, only: %i[index update] do
    collection { post :read_all }
  end

  namespace :admin do
    root to: "dashboards#show"
    resource  :dashboard, only: :show
    resources :managers
    resources :categories, except: :show
    resources :resolution_types, except: :show
  end

  namespace :manager do
    root to: "dashboards#show"
    resource  :dashboard, only: :show
    resources :officers
    resources :issues, only: %i[index show]
  end

  namespace :officer do
    root to: "dashboards#show"
    resource  :dashboard, only: :show
    resources :issues, only: %i[index show] do
      resource :resolution, only: %i[new create]
      resource :assignment, only: %i[create destroy]
    end
    resources :locations, only: :create
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "pages#home"
end
