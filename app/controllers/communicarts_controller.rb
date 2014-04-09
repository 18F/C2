class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_cart
    params['cartItems'].each do |cart_item_params|
      Cart.create_from_cart_items(cart_item_params)
    end

    CommunicartMailer.cart_notification_email(params).deliver
    render json: { message: "This was a success"}, status: 200
  end

  def approval_reply_received
    Approval.update_statuses(params)

    CommunicartMailer.approval_reply_received_email(params).deliver
    render json: { message: "approval_reply_received"}, status: 200
  end
end
