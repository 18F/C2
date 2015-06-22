C2::Application.routes.draw do
  root :to => 'home#index'
  get '/help' => 'home#help'
  get '/error' => 'home#error'
  get '/feedback' => 'feedback#index'
  post '/feedback' => 'feedback#create'

  match '/auth/:provider/callback' => 'auth#oauth_callback', via: [:get]
  post '/logout' => 'auth#logout'

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
    "/proposals/#{cart.proposal_id}"
  }

  resources :proposals, only: [:index, :show] do
    member do
      get 'approve'   # this route has special protection to prevent the confused deputy problem
                      # if you are adding a new controller which performs an action, use post instead
      post 'approve'
    end

    collection do
      get 'archive'
      get 'query'
    end

    resources :comments, only: :create
    resources :attachments, only: [:create, :destroy, :show]
  end

  namespace :ncr do
    resources :work_orders, except: [:index, :destroy]
    get '/dashboard' => 'dashboard#index'
  end

  namespace :gsa18f do
    resources :procurements, except: [:index, :destroy]
    get '/dashboard' => 'dashboard#index' 
  end

  if Rails.env.development?
    mount MailPreview => 'mail_view'
    mount LetterOpenerWeb::Engine => 'letter_opener'
  end
end
