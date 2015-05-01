# Usage:
#
# class CommunicartsController < ApplicationController
#   include TokenAuth
#   before_filter :validate_access, only: :approval_response
#   ...
# end

# TODO remove references to `cart`
module TokenAuth
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError, with: :auth_errors
  end

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
      raise Pundit::NotAuthorizedError.new(
        "This request has recently changed. Please review the modified request before approving.")
    end
  end

  def auth_errors(exception)
    if exception.record == :api_token
      session[:return_to] = request.fullpath
      if signed_in?
        flash[:error] = exception.message
        render 'authentication_error', status: 403
      else
        redirect_to root_path, alert: "Please sign in to complete this action."
      end
    else
      flash[:error] = exception.message
      redirect_to proposal_path(self.cart.proposal)
    end
  end
end
