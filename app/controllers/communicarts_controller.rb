class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_cart
    Cart.initialize_cart_with_items(params)
    CommunicartMailer.cart_notification_email(params).deliver
    render json: { message: "This was a success"}, status: 200
  end

  def approval_reply_received
    CommunicartMailer.approval_reply_received_email(params).deliver
    render json: { message: "approval_reply_received"}, status: 200
  end
end
