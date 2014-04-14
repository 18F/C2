class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_cart
    jparams = params
    Cart.initialize_cart_with_items(jparams)
    
    approval_group_name = jparams['approvalGroup']

    # Here we compute the prices of that jparams
    # We add it back into the jparams
    # jparams.merge(totalPriceValue: 5.55)
    sum = jparams["cartItems"].reduce(0) do |sum,value|
      sum + value["qty"].gsub(/[^\d\.]/, '').to_f + value["price"].gsub(/[^\d\.]/, '').to_f
    end
    jparams = jparams.merge({ totalPriceValue: sum })

    if !approval_group_name.blank?
      approval_group = ApprovalGroup.find_by name:approval_group_name
      approval_group.approvers.each do | approver |
        CommunicartMailer.cart_notification_email(approver.email_address,jparams).deliver
      end
    else
      CommunicartMailer.cart_notification_email(jparams["email"],jparams).deliver
    end
    render json: { message: "This was a success"}, status: 200
  end

  def approval_reply_received
    CommunicartMailer.approval_reply_received_email(jparams).deliver
    render json: { message: "approval_reply_received"}, status: 200
  end
end
