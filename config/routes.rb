C2::Application.routes.draw do
  post 'communicarts/send_cart' => 'communicarts#send_cart'
end
