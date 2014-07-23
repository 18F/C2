C2::Application.routes.draw do
  resources :approval_groups
  post 'send_cart' => 'communicarts#send_cart'
  post 'approval_reply_received' => 'communicarts#approval_reply_received'
  match 'approval_response', to: 'communicarts#approval_response', via: [:get, :put]

  get "/498", :to => "errors#token_authentication_error"

end




