C2::Application.routes.draw do
  post 'send_cart' => 'communicarts#send_cart'
end
