Rails.application.routes.draw do
  root "home#index"

  devise_for :users,
             defaults: { format: :json },
             controllers: {
               sessions: "users/sessions",
               registrations: "users/registrations"
             }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :health_check, only: [ :index ]
      resources :products, only: [ :index, :show ]

      resources :orders do
        collection do
          get :current
        end
        member do
          post :submit
          post :calculate_shipping
          post :process_payment
        end
        resources :line_items
        resources :shipping_rates, only: [] do
          collection do
            post :calculate
          end
        end
      end
      resources :carts, only: [ :show, :create, :update, :destroy ] do
        resources :cart_items, only: [ :create, :update, :destroy ]
      end
      resources :discounts, only: [ :index, :show ]
      resources :addresses, only: [ :index, :create ]
      get "health/check", to: "health#check"
    end
  end

  # Admin routes
  namespace :admin do
    resources :products
    resources :orders do
      member do
        post :process_refund
        post :add_note
      end
    end
    resources :discounts
    resources :users, only: [ :index, :show, :update ] do
      member do
        post :toggle_admin
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Client-side routes
  get "/checkout", to: "home#index"
  get "/orders/confirmation", to: "home#index"
  get "*path", to: "home#index"

  # Defines the root path route ("/")
  # root "posts#index"
end
