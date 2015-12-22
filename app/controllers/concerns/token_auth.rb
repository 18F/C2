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
      user_id: current_user, proposal_id: proposal})
    tokens.where(used_at: nil).update_all(used_at: Time.zone.now)

    authorize(proposal, :can_approve!)

    if params[:version] && params[:version] != proposal.version.to_s
      raise Pundit::NotAuthorizedError.new(
        "This request has recently changed. Please review the modified request before approving.")
    end
  end

  def auth_errors(exception)
    case exception.record
    when :api_token
      render_api_token_exception(exception)
    when Proposal
      if exception.message == "A response has already been logged for this proposal"
        flash[:error] = exception.message
        redirect_to proposal
      else
        render "authorization_error", status: 403, locals: { msg: "You are not allowed to see that proposal." }
      end
    else
      render_other_exception(exception)
    end
  end

  def render_api_token_exception(exception)
    if signed_in?
      flash[:error] = exception.message
      render "authentication_error", status: 403
    else
      return_to_param = make_return_to("Previous", request.fullpath)
      session[:return_to] = return_to_param
      redirect_to root_path(return_to: return_to_param), alert: "Please sign in to complete this action."
    end
  end

  def render_other_exception(exception)
    if exception.message == "Client is disabled"
      render_disabled_client_message(exception.message)
    else
      flash[:error] = exception.message
      redirect_to proposal
    end
  end
end
