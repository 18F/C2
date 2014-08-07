C2::Application.routes.draw do
  post 'send_cart' => 'communicarts#send_cart'
  post 'approval_reply_received' => 'communicarts#approval_reply_received'
  match 'approval_response', to: 'communicarts#approval_response', via: [:get, :put]
  root :to => 'home#index'
  match "/auth/:provider/callback" => "home#oauth_callback", via: [:get]
  post "/logout" => "home#logout"

  get "/498", :to => "errors#token_authentication_error"

end




