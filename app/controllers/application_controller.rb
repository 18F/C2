class ApplicationController < ActionController::Base
  include Pundit    # For authorization checks
  include ReturnToHelper
  include MarkdownHelper

  helper ValueHelper
  add_template_helper ClientHelper

  protect_from_forgery with: :exception
  helper_method :current_user, :signed_in?, :return_to

  protected
  # We are overriding this method to account for ExceptionPolicies
  def authorize(record, query=nil, user=nil)
    user ||= @current_user
    record = self.authorizing_object(record)
    policy = Pundit.policy(user, record)

    # use the action as a default permission
    query ||= ("can_" + params[:action].to_s + "!").to_sym
    unless policy.public_send(query)
      # the method might raise its own exception, or it might return a
      # boolean. Both systems are accommodated
      # will need to replace this when a new version of pundit arrives
      ex = NotAuthorizedError.new("not allowed to #{q} this #{record}")
      ex.query, ex.record, ex.policy = q, record, pol
      raise ex
    end
  end

  # Proposals can have special authorization parameters in their client_data
  def authorizing_object(record)
    if record.instance_of?(Proposal) && Pundit::PolicyFinder.new(record.client_data).policy
      record.client_data
    else
      record
    end
  end
  
  # Override Pundit to account for proposal gymnastics
  def policy(record)
    super(self.authorizing_object(record))
  end

  def param_date(sym)
    begin
      Date.strptime(params[sym].to_s)
    rescue ArgumentError
      nil
    end
  end

  private

  def current_user
    @current_user ||= User.find_or_create_by(email_address: session[:user]['email']) if session[:user] && session[:user]['email']
  end

  def sign_in(user)
    session[:user] ||= {}
    session[:user]['email'] = user.email_address
    @current_user = user
  end

  def sign_out
    reset_session
    @current_user = nil
  end

  def signed_in?
    !!current_user
  end

  def authenticate_user!
    unless signed_in?
      flash[:error] = 'You need to sign in for access to this page.'
      redirect_to root_url(return_to: self.make_return_to("Previous", request.fullpath))
    end
  end
end
