class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_cart
    Cart.initialize_cart_with_items(params)

    # Note: There surely should be a better way to fill this in since we just
    # create the object above, but I don't really know how to do that...
    cart = Cart.where(external_id: (params['cartNumber'].to_i)).where(status: 'pending').first.decorate

    Comment.create(comment_text: params['initiationComment'].strip, cart_id: cart.id) unless params['initiationComment'].blank?


    sum = params['cartItems'].reduce(0) do |sum,value|
      sum + (value["qty"].gsub(/[^\d\.]/, '').to_f *  value["price"].gsub(/[^\d\.]/, '').to_f)
    end
    params['totalPrice'] = "%0.2f" % sum

    approval_group_name = params['approvalGroup']

    if !approval_group_name.blank?
      approval_group = ApprovalGroup.find_by(name: approval_group_name)
      unless duplicated_approvals_exist_for(cart)
        approval_group.user_roles.each do | user_role |
          Approval.create!(user_id: user_role.user_id, cart_id: cart.id, role: user_role.role)
          CommunicartMailer.cart_notification_email(user_role.user.email_address, cart).deliver if user_role.role == "approver"
        end
      end
    else
      #No approval group is indicated, so create an approval with the user that was passed in.
      #TODO: require a user to be sent if approval group isn't indicated
      approval_user = User.find_or_create_by(email_address: params["email"])
      Approval.create!(user_id: approval_user.id, cart_id: cart.id, role: 'approver')
      CommunicartMailer.cart_notification_email(params["email"], cart).deliver
    end

    render json: { message: "This was a success"}, status: 200
  end

  def duplicated_approvals_exist_for(cart)
    cart.approvals.count > 0
  end

  def approval_reply_received
    cart = Cart.where(external_id: (params['cartNumber'].to_i)).where(status:'pending').first.decorate
    user = cart.approval_users.where(email_address: params['fromAddress']).first

    ApproverComment.create(comment_text: params['comment'].strip, user_id: user.id) unless params['comment'].blank?
    Comment.create(comment_text: params['comment'].strip, cart_id: cart.id) unless params['comment'].blank?

    approval = cart.approvals.where(user_id: user.id).first
    approval.update_attributes(status: approve_or_reject_status)
    cart.update_approval_status
    CommunicartMailer.approval_reply_received_email(params, cart).deliver
    render json: { message: "approval_reply_received"}, status: 200

    perform_reject_specific_actions(params, cart) if approve_or_reject_status == 'rejected'
  end


private

  def perform_reject_specific_actions(params, cart)
    # Send out a rejection status email to the approvers
    cart.approvals.each do |approval|
      CommunicartMailer.rejection_update_email(params, cart).deliver
    end

    # Reset everything for the next time they send a cart request
  end

  def approve_or_reject_status
    #TODO: Refactor duplication with ComunicartMailer#approval_reply_received_email
    return 'approved' if params["approve"] == "APPROVE"
    return 'rejected' if params["disapprove"] == "REJECT"
  end
end
