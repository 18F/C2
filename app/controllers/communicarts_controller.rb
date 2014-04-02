class CommunicartsController < ApplicationController
  def send_cart
    CommunicartMailer.cart_notification_email(@user).deliver
    render json: { message: "This was a success"}, status: 200
  end
end
