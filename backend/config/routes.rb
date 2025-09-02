Rails.application.routes.draw do
  # devise_for :users
  devise_for :users, defaults: { format: :json }, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  namespace :api do
    namespace :v1 do
      resources :posts
      resources :locations, only: [ :index, :show, :create, :update, :destroy ]
      resources :trips, only: [:index, :show, :create, :update, :destroy] do
        resources :trip_locations, only: [:index, :create, :update, :destroy]
        resources :travel_buddies, only: [:index, :create, :update, :destroy]
      end
      resources :countries, only: [ :index, :show ] do
        collection do
          get :search
        end
      end
      resources :users, only: [:show] do
        collection { get :search }
      end
      resources :pictures, only: %i[index show create update destroy] do
        resources :tags, only: [:index, :create, :destroy]
      end
      resources :videos,   only: %i[index show create update destroy] do
        resources :tags, controller: 'video_tags', only: [:index, :create, :destroy]
      end
      resources :audios,   only: %i[index show create update destroy]      
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
