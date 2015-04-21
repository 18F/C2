C2::Application.routes.draw do
  post 'send_cart' => 'communicarts#send_cart'
  match 'approval_response', to: 'communicarts#approval_response', via: [:get, :put]
  root :to => 'home#index'
  match "/auth/:provider/callback" => "home#oauth_callback", via: [:get]
  get '/error' => 'home#error'
  post "/logout" => "home#logout"

  namespace :api do
    scope :v1 do
      namespace :ncr do
        resources :work_orders, only: [:index]
      end

      resources :users, only: [:index]
    end
  end

  resources :carts, only: [:index, :show] do
    collection do
      get 'archive'
    end

    resources :comments, only: [:index, :create]
  end

  # todo: integrate once proposal urls are complete
  resources :proposals, only: [] do
    resources :attachments, only: [:create]
  end

  namespace :ncr do
    resources :work_orders, except: [:index, :destroy]
  end

  namespace :gsa18f do
    resources :proposals, except: [:index, :destroy]
  end

  if Rails.env.development?
    mount MailPreview => 'mail_view'
    mount LetterOpenerWeb::Engine => 'letter_opener'
  end
end
