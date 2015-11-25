C2::Application.routes.draw do
  ActiveAdmin.routes(self)
  root to: "home#index"
  get '/error' => 'home#error'
  get '/profile'  => 'profile#show'
  post '/profile' => 'profile#update'
  get '/feedback' => 'feedback#index'
  get '/feedback/thanks' => 'feedback#thanks'
  post '/feedback' => 'feedback#create'

  match '/auth/:provider/callback' => 'auth#oauth_callback', via: [:get]
  post '/logout' => 'auth#logout'

  resources :help, only: [:index, :show]

  # mandrill-rails
  resource :inbox, controller: 'inbox', only: [:show, :create]

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
      get 'approve'   # this route has special protection to prevent the confused deputy problem
                      # if you are adding a new controller which performs an action, use post instead
      post 'approve'
      get 'cancel_form'
      post 'cancel'
      get 'history'
    end

    collection do
      get 'archive'
      get 'query'
    end

    resources :comments, only: :create
    resources :attachments, only: [:create, :destroy, :show]
    resources :observations, only: [:create, :destroy]
  end

  namespace :ncr do
    resources :work_orders, except: [:index, :destroy]
    get '/dashboard' => 'dashboard#index'
  end

  namespace :gsa18f do
    resources :procurements, except: [:index, :destroy]
    get '/dashboard' => 'dashboard#index'
  end

  mount Peek::Railtie => '/peek'
  if Rails.env.development?
    mount MailPreview => 'mail_view'
    mount LetterOpenerWeb::Engine => 'letter_opener'
  end
end
