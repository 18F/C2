require ::File.expand_path('authentication_error.rb',  'lib/errors')

class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :validate_access, only: :approval_response

  rescue_from AuthenticationError do |exception|
    authentication_error(exception)
  end

  def send_cart
    cx = Cart.initialize_cart_with_items(params)
    cart = Cart.find(cx.id)
    cart.decorate
    Comment.create(comment_text: params['initiationComment'].strip, cart_id: cart.id) unless params['initiationComment'].blank?
    cart.create_and_send_approvals unless duplicated_approvals_exist_for(cart)

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

  def approval_response
    Commands::Approval::UpdateFromApprovalResponse.new.perform(params)
    @token.update_attributes(used_at: Time.now)

    flash[:notice] = "You have successfully updated Cart (no. 12345). See the cart details below"
  end


private

  def validate_access
    raise AuthenticationError.new(message: 'something went wrong with the token (nonexistent)') unless @token = ApiToken.find_by(access_token: params[:cch])

    if @token.expires_at && @token.expires_at < Time.now
      raise AuthenticationError.new(message: 'something went wrong with the token (expired)')
    end

    raise AuthenticationError.new(msg: 'Something went wrong with the token. It has already been used.') unless @token.used_at.nil?
    raise AuthenticationError.new(msg: 'Something went wrong with the user (wrong person)') unless @token.user_id == params[:user_id].to_i
    raise AuthenticationError.new(msg: 'Something went wrong with the cart (wrong cart)') unless @token.cart_id == params[:cart_id].to_i
  end

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

  def authentication_error(e)
    flash[:notice] = e.message
    redirect_to "/498.html"
  end
end
