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
    approval = proposal.approval_for(current_user)

    case params[:approver_action]
      when 'approve'
        approval.approve!
        unless approval.user == current_user
          # delegate - assign them to the approval
          approval.update_attributes!(user_id: current_user.id)
        end

        flash[:success] = "You have approved Cart #{proposal.public_identifier}."
      when 'reject'
        approval.reject!
        flash[:success] = "You have rejected Cart #{proposal.public_identifier}."
    end

    redirect_to proposal_path(proposal)
  end


  protected

  def validate_access
    if !signed_in?
      authorize(:api_token, :valid!, params)
      # validated above
      sign_in(ApiToken.find_by(access_token: params[:cch]).user)
    end
    # expire tokens regardless of how user logged in
    tokens = ApiToken.joins(:approval).where(approvals: {
      user_id: current_user, proposal_id: self.cart.proposal})
    tokens.where(used_at: nil).update_all(used_at: Time.now)

    authorize(self.cart.proposal, :can_approve_or_reject!)
    if params[:version] && params[:version] != self.cart.proposal.version.to_s
      raise NotAuthorizedError.new(
        "This request has recently changed. Please review the modified request before approving.")
    end
  end

  def auth_errors(exception)
    flash[:error] = exception.message
    if exception.record == :api_token
      render 'authentication_error', status: 403
    else
      redirect_to proposal_path(self.cart.proposal)
    end
  end

  def approval_group_error(error)
    render json: { message: error.to_s }, status: 400
  end

  def cart
    @cached_cart ||= Cart.find(params[:cart_id])
  end
end
