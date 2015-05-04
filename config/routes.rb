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

  # Redirects for carts. @todo Eventually, delete
  get "/carts", to: redirect("/proposals")
  get "/carts/archive", to: redirect("/proposals/archive")
  get "/carts/:id", to: redirect { |path_params, req|
    cart = Cart.find(path_params[:id])
    "/proposals/" + cart.proposal.id.to_s
  }

  resources :proposals, only: [:index, :show] do
    collection do
      get 'archive'
      get 'query'
    end

    resources :comments, only: [:index, :create]
    resources :attachments, only: [:create, :destroy]
  end

  namespace :ncr do
    resources :work_orders, except: [:index, :destroy]
    get '/dashboard' => 'dashboard#index'
  end

  namespace :gsa18f do
    resources :procurements, except: [:index, :destroy]
  end

  if Rails.env.development?
    mount MailPreview => 'mail_view'
    mount LetterOpenerWeb::Engine => 'letter_opener'
  end
end
