class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_cart
    cx = Cart.initialize_cart_with_items(params)
    cart = Cart.find(cx.id)
    cart.decorate
    Comment.create(comment_text: params['initiationComment'].strip, cart_id: cart.id) unless params['initiationComment'].blank?
    cart.create_and_send_approvals unless duplicated_approvals_exist_for(cart)

    render json: { message: "This was a success"}, status: 200
  end

  def create_informal_cart
    # This is creating a bogus item, but really, we need to do some NLP to compute them---
    # AND also get this working with Mario.
    cx = Cart.initialize_informal_cart(params)
    cart = Cart.find(cx.id)
    cart.decorate
    cart.setProp('original',params['body'])

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
    cart.approvals.where(role: 'approver').each do |approval|
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
