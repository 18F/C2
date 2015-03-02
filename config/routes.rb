C2::Application.routes.draw do
  post 'send_cart' => 'communicarts#send_cart'
  post 'approval_reply_received' => 'communicarts#approval_reply_received'
  match 'approval_response', to: 'communicarts#approval_response', via: [:get, :put]
  root :to => 'home#index'
  match "/auth/:provider/callback" => "home#oauth_callback", via: [:get]
  post "/logout" => "home#logout"
  get 'overlay', to: "overlay#index"

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

  resources :cart_items, only: [] do
    resources :comments, only: [:index, :create]
  end

  namespace :ncr do
    resources :proposals
  end

  get 'bookmarklet', to: redirect('bookmarklet.html')
  get "/498", :to => "errors#token_authentication_error"

  if Rails.env.development?
    mount MailPreview => 'mail_view'
    mount LetterOpenerWeb::Engine => 'letter_opener'
  end
end
