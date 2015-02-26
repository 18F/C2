C2::Application.routes.draw do
  get 'approval_groups/search' => "approval_groups#search"
  resources :approval_groups
  post 'send_cart' => 'communicarts#send_cart'
  post 'approval_reply_received' => 'communicarts#approval_reply_received'
  match 'approval_response', to: 'communicarts#approval_response', via: [:get, :put]
  root :to => 'home#index'
  match "/auth/:provider/callback" => "home#oauth_callback", via: [:get]
  post "/logout" => "home#logout"
  get 'carts/archive' => 'carts#archive'

  resources :carts do
    resources :comments
  end

  resources :cart_items do
    resources :comments
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
