require ::File.expand_path('authentication_error.rb',  'lib/errors')

class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :validate_access, only: :approval_response

  rescue_from AuthenticationError do |exception|
    authentication_error(exception)
  end

  def send_cart
    cart = Commands::Approval::InitiateCartApproval.new.perform(params)
    jcart = cart.as_json(include: {cart_items:
                                       {
                                           include: :cart_item_traits
                                       }
    })
    render json: jcart, status: 201
    # TODO respond with JSON in case of error
    # render json: { message: "Something went wrong", errors: e }, status: 500
  end

  def approval_reply_received
    cart = Cart.where(external_id: (params['cartNumber'].to_i)).where(status:'pending').first
    user = cart.approval_users.where(email_address: params['fromAddress']).first

    if params['comment']
      new_comment = Comment.new(user_id: user.id,comment_text: params['comment'].strip)
      cart.comments << new_comment
    end

    approval = cart.approvals.where(user_id: user.id).first
    Commands::Approval::UpdateFromApprovalResponse.new.perform(approval, approve_or_reject_status)
    render json: { message: "approval_reply_received"}, status: 200

    perform_reject_specific_actions(params, cart) if approve_or_reject_status == 'rejected'
  end

  def approval_response
    @cart = Cart.find_by(id: params[:cart_id].to_i).decorate
    @approval = @cart.approvals.where(user_id: params[:user_id]).first
    action = params[:approver_action]
    new_status = Cart::APPROVAL_ATTRIBUTES_MAP[action.to_sym]

    Commands::Approval::UpdateFromApprovalResponse.new.perform(@approval, new_status)
    @token.update_attributes(used_at: Time.now)

    flash[:notice] = "You have successfully updated Cart #{@cart.external_id}. See the cart details below"
  end


private

  def validate_access
    raise AuthenticationError.new(msg: 'something went wrong with the token (nonexistent)') unless @token = ApiToken.find_by(access_token: params[:cch])

    if @token.expires_at && @token.expires_at < Time.now
      raise AuthenticationError.new(msg: 'something went wrong with the token (expired)')
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
    flash[:error] = e.message
    redirect_to "/498.html"
  end
end
