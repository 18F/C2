class ApplicationController < ActionController::Base
  include Pundit    # For authorization checks

  helper TimeHelper
  add_template_helper ClientHelper

  protect_from_forgery with: :exception
  helper_method :current_user, :signed_in?

  protected
  # We are overriding this method to account for permission trees. See
  # TreePolicy
  def authorize(record, query=nil)
    if query.nil?
      query = (params[:action].to_s + "?").to_sym
    end

    pol = policy(record)
    if pol.respond_to?(:flatten_tree)
      queries = pol.flatten_tree(query)
    else
      queries = [query]
    end

    queries.each do |q|
      super(record, q)  # default processing
    end

    true
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
      session[:return_to] = request.fullpath
      redirect_to root_url, :alert => 'You need to sign in for access to this page.'
    end
  end

end
