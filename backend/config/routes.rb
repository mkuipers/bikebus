Rails.application.routes.draw do
  devise_for :users,
    path: "auth",
    path_names: { sign_in: "sign_in", sign_out: "sign_out", registration: "sign_up" },
    controllers: {
      sessions: "auth/sessions",
      registrations: "auth/registrations"
    }

  resources :device_tokens, only: [:create]

  resources :routes, only: [:index, :show, :create, :update, :destroy] do
    resources :stops, only: [:create], shallow: true
    resources :schedules, only: [:create], shallow: true
  end

  resources :rides, only: [:index, :show] do
    member do
      post :claim_leader
      post :release_leader
      post :complete
    end
  end

  resources :subscriptions, only: [:index, :create, :destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
