C2::Application.routes.draw do
  ActiveAdmin.routes(self)
  root to: "home#index"
  get "/error" => "home#error"
  get "/profile"  => "profile#show"
  post "/profile" => "profile#update"
  get "/summary" => "summary#index"
  get "/summary/:fiscal_year" => "summary#index"
  get "/feedback" => "feedback#index"
  get "/feedback/thanks" => "feedback#thanks"
  post "/feedback" => "feedback#create"

  match "/auth/:provider/callback" => "auth#oauth_callback", via: [:get]
  get "/auth/failure" => "auth#failure"
  post "/logout" => "auth#logout"

  resources :help, only: [:index, :show]

  # mandrill-rails
  resource :inbox, controller: "inbox", only: [:show, :create]

  namespace :api do
    scope :v1 do
      namespace :ncr do
        resources :work_orders, only: [:index]
      end

      resources :users, only: [:index]
    end
  end

  resources :proposals, only: [:index, :show] do
    member do
      get "approve"   # this route has special protection to prevent the confused deputy problem
      get "complete"  # if you are adding a new controller which performs an action, use post instead
      post "complete"
      post "approve"

      get "cancel_form"
      post "cancel"
      get "history"
    end

    collection do
      get "archive"
      get "download", defaults: { format: "csv" }
      get "query"
      get "query_count"
    end

    resources :comments, only: :create
    resources :attachments, only: [:create, :destroy, :show]
    resources :observations, only: [:create, :destroy]
  end

  resources :reports, only: [:index, :show, :create, :destroy] do
    member do
      post :preview
    end
  end
  resources :scheduled_reports, only: [:create, :update]

  namespace :ncr do
    resources :work_orders, except: [:index, :destroy]
    get "/dashboard" => "dashboard#index"
  end

  namespace :gsa18f do
    resources :procurements, except: [:index, :destroy]
    get "/dashboard" => "dashboard#index"
  end

  mount Peek::Railtie => "/peek"
  if Rails.env.development?
    mount LetterOpenerWeb::Engine => "letter_opener"
    mount Blazer::Engine, at: "blazer"
    mount Konacha::Engine, at: "konacha" if defined?(Konacha)
  end
end
