require ::File.expand_path('authentication_error.rb',  'lib/errors')
require ::File.expand_path('approval_group_error.rb',  'lib/errors')


class CommunicartsController < ApplicationController
  before_filter :validate_access, only: :approval_response
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  rescue_from ApprovalGroupError, with: :approval_group_error

  def send_cart
    cart = Commands::Approval::InitiateCartApproval.new.perform(params)
    jcart = cart.as_json
    render json: jcart, status: 201
  end

  def approval_response
    proposal = self.cart.proposal
    approval = cart.approvals.find_by(user_id: current_user.id)

    case params[:approver_action]
      when 'approve'
        approval.approve!
        flash[:success] = "You have approved Cart #{proposal.public_identifier}."
      when 'reject'
        approval.reject!
        flash[:success] = "You have rejected Cart #{proposal.public_identifier}."
    end

    redirect_to cart_path(cart)
  end


  protected

  def validate_access
    if !signed_in?
      authorize(:api_token, :is_valid?, params)
      # validated above
      sign_in(ApiToken.find_by(access_token: params[:cch]).user)
    end
    # expire tokens regardless of how user logged in
    tokens = ApiToken.joins(:approval).where(approvals: {
      user_id: current_user, proposal_id: self.cart.proposal})
    tokens.where(used_at: nil).update_all(used_at: Time.now)

    authorize(self.cart.proposal, :can_approve_or_reject?)
    # Imitate an authorization error
    # will need to replace this when a new version of pundit arrives
    if params[:version] && params[:version] != self.cart.proposal.version.to_s
      ex = NotAuthorizedError.new("not allowd to update this proposal")
      ex.query, ex.record = :is_up_to_date?, self.cart.proposal
      raise ex
    end
  end

  def token_validation_errors(query)
    message = "Something went wrong with the token "
    case query
    when :exists?
      message += "(nonexistent)"
    when :is_not_expired?
      message += "(expired)"
    when :is_not_used?
      message += "(already used)"
    when :is_correct_cart?
      message += "(wrong cart)"
    end
    flash[:error] = message
    render 'authentication_error', status: 403
  end

  def user_access_errors(query, default_message)
    case query
    when :is_approver?
      message = "Sorry, you're not an approver on #{self.cart.proposal.public_identifier}."
    when :is_pending_approver?
      message = "You have already logged a response for Cart #{self.cart.proposal.public_identifier}."
    when :is_up_to_date?
      message = "This request has recently changed. Please review the modified request before approving."
    else
      message = default_message
    end
    flash[:error] = message
    redirect_to cart_path(self.cart)
  end

  def auth_errors(exception)
    if exception.record == :api_token
      self.token_validation_errors(exception.query)
    else
      self.user_access_errors(exception.query, exception.message)
    end
  end

  def approval_group_error(error)
    render json: { message: error.to_s }, status: 400
  end

  def cart
    @cached_cart ||= Cart.find(params[:cart_id])
  end
end
