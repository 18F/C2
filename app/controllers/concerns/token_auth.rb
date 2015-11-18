module TokenAuth
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError, with: :auth_errors
  end

  # As a security precaution, certain actions must be POSTed to.
  def needs_token_on_get
    if request.get?
      authorize(:api_token, :valid!, params)
    end
  end

  def validate_access
    if not_signed_in?
      authorize(:api_token, :valid_and_not_delegate!, params)

      token = ApiToken.find_by(access_token: params[:cch])
      sign_in(token.user)
    end

    # expire tokens regardless of how user logged in
    tokens = ApiToken.joins(:step).where(steps: {
      user_id: current_user, proposal_id: self.proposal})
    tokens.where(used_at: nil).update_all(used_at: Time.zone.now)

    authorize(self.proposal, :can_approve!)

    if params[:version] && params[:version] != self.proposal.version.to_s
      raise Pundit::NotAuthorizedError.new(
        "This request has recently changed. Please review the modified request before approving.")
    end
  end

  def auth_errors(exception)
    case exception.record
    when :api_token
      if signed_in?
        flash[:error] = exception.message
        render "authentication_error", status: 403
      else
        return_to_param = make_return_to("Previous", request.fullpath)
        session[:return_to] = return_to_param
        redirect_to root_path(return_to: return_to_param), alert: "Please sign in to complete this action."
      end
    when Proposal
      render "authorization_error", status: 403, locals: { msg: "You are not allowed to see that proposal." }
    else
      flash[:error] = exception.message
      redirect_to self.proposal
    end
  end
end
