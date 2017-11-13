class ApplicationController < ActionController::Base
  include Pundit
  include ReturnToHelper
  include MarkdownHelper

  helper ValueHelper
  add_template_helper ClientHelper
  add_template_helper SearchHelper

  protect_from_forgery with: :exception
  helper_method :current_user, :signed_in?, :return_to, :client_disabled?

  before_action :check_maintenance_mode
  before_action :authenticate_user!
  before_action :disable_peek_by_default
  before_action :check_disabled_client
  before_action :set_default_view_variables

  after_action :track_action

  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def authenticate(scope = nil, block = nil)
    constraints_for(:authenticate!, scope, block) do
      yield
    end
  end

  protected

  # We are overriding this method to account for ExceptionPolicies
  def authorize(record, query = nil, user = nil)
    check_disabled_client
    user ||= current_user
    policy = ::PolicyFinder.policy_for(user, record)

    # use the action as a default permission
    query ||= ("can_" + params[:action].to_s + "!").to_sym
    unless policy.public_send(query)
      # the method might raise its own exception, or it might return a
      # boolean. Both systems are accommodated
      # will need to replace this when a new version of pundit arrives
      msg = "not allowed to #{query} this #{record}"
      exception = NotAuthorizedError.new(query: query, record: record, policy: policy, message: msg)
      fail exception
    end
  end

  def check_disabled_client
    if client_disabled?
      exception = NotAuthorizedError.new("Client is disabled")
      fail exception
    end
  end

  def check_maintenance_mode
    render_maintenance if maintenance_mode?
  end

  def render_maintenance
    render "maintenance"
  end

  def track_action
    ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
  end

  def render_disabled_client_message(message)
    begin
      render "#{current_user.client_slug}/_disabled", status: 403
    rescue ActionView::MissingTemplate => _error
      render "authorization_error", status: 403, locals: { msg: message }
    end
  end

  def auth_errors(exception)
    render_auth_errors(exception)
  end

  def render_auth_errors(exception)
    if exception.message == "Client is disabled"
      render_disabled_client_message(exception.message)
    else
      render "authorization_error", status: 403, locals: { msg: exception.message }
    end
  end

  # Override Pundit to account for proposal gymnastics
  def policy(record)
    obj = ::PolicyFinder.authorizing_object(record)
    super(obj)
  end

  def admin?
    signed_in? && current_user.admin?
  end

  def peek_enabled?
    Rails.env.development? || admin?
  end

  private

  def current_user
    @current_user ||= find_current_user
  end
  # ahoy_matey gem uses this accessor:
  alias current_resource_owner current_user

  def find_current_user
    if ENV["FORCE_USER_ID"] && !Rails.env.production?
      User.find ENV["FORCE_USER_ID"]
    else
      find_current_user_via_session_or_doorkeeper
    end
  end

  def find_current_user_via_session_or_doorkeeper
    if session[:user] && session[:user]["email"]
      User.find_or_create_by(email_address: session[:user]["email"])
    elsif doorkeeper_token
      doorkeeper_token.application.owner
    end
  end

  def client_disabled?
    current_user && (ENV["DISABLE_CLIENT_SLUGS"] || "").split(/,/).include?(current_user.client_slug)
  end

  def maintenance_mode?
    ENV["MAINTENANCE_MODE"] == "true"
  end

  def sign_in(user)
    session[:user] ||= {}
    session[:user]["email"] = user.email_address
    user.check_beta_state
    @current_user = user
  end

  def sign_out
    reset_session
    @current_user = nil
  end

  def signed_in?
    Rails.logger.info("Authentication check: #{current_user}")
    current_user.present?
  end

  def setup_flash_manager
    @flash_manager = @current_user.active_beta_user? ? FlashWithNow.new : FlashWithoutNow.new
  end

  def authenticate_user!
    if not_signed_in?
      flash[:error] = I18n.t("errors.authentication")
      return_to_param = make_return_to("Previous", request.fullpath)
      session[:return_to] = return_to_param
      redirect_to root_url(return_to: return_to_param)
    elsif current_user.deactivated?
      redirect_to feedback_path
    end
  end

  def set_default_view_variables
    @adv_search = ProposalFieldedSearchQuery.new({})
  end

  def authenticate_admin_user!
    render "authorization_error", status: 403 if current_user.not_admin?
  end

  def disable_peek_by_default
    cookies[:peek] = false if cookies[:peek].nil?
  end

  def not_signed_in?
    !signed_in?
  end
end
