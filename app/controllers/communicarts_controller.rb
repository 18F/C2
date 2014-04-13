class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_cart
    Cart.initialize_cart_with_items(params)

    approval_group_name = params['approvalGroup']
    if !approval_group_name.blank?
      approval_group = ApprovalGroup.find_by name:approval_group_name
      approval_group.approvers.each do | approver |
        CommunicartMailer.cart_notification_email(approver.email,params).deliver
      end
    else
      CommunicartMailer.cart_notification_email(params["email"],params).deliver
    end
    render json: { message: "This was a success"}, status: 200
  end

  def approval_reply_received
    CommunicartMailer.approval_reply_received_email(params).deliver
    render json: { message: "approval_reply_received"}, status: 200
  end
end
