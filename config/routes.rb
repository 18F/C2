C2::Application.routes.draw do
  post 'send_cart' => 'communicarts#send_cart'
  match 'approval_response', to: 'communicarts#approval_response', via: [:get, :put]
  root :to => 'home#index'
  match "/auth/:provider/callback" => "home#oauth_callback", via: [:get]
  get '/error' => 'home#error'
  post "/logout" => "home#logout"

  namespace :api, constraints: lambda {|req| ENV['API_ENABLED'] == 'true' } do
    scope :v1 do
      namespace :ncr do
        resources :work_orders, only: [:index]
      end
    end
  end

  resources :approval_groups, except: [:edit, :update] do
    collection do
      get 'search'
    end
  end

  resources :carts, only: [:index, :show] do
    collection do
      get 'archive'
    end

    resources :comments, only: [:index, :create]
  end

  namespace :ncr do
    resources :work_orders
  end

  namespace :gsa18f do
    resources :proposals
  end

  if Rails.env.development?
    mount MailPreview => 'mail_view'
    mount LetterOpenerWeb::Engine => 'letter_opener'
  end
end
