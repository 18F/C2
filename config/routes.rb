C2::Application.routes.draw do
  post 'send_cart' => 'communicarts#send_cart'
  post 'create_informal_cart' => 'communicarts#create_informal_cart'
  post 'approval_reply_received' => 'communicarts#approval_reply_received'
end




