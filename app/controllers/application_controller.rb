class ApplicationController < ActionController::Base
  before_filter :allow_cors_request
  after_filter :cors_set_access_control_headers
  protect_from_forgery with: :exception

  helper_method :current_user, :user_signed_in?

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def allow_cors_request
    if request.method == :options
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      render :text => '', :content_type => 'text/plain'
    end
  end

private
  def current_user
    @current_user ||= User.find_or_create_by(email_address: session[:user]['email']) if session[:user]
  end

  def user_signed_in?
    !!current_user
  end

  def authenticate_user!
    unless current_user
      session[:return_to] = request.fullpath
      redirect_to root_url, :alert => 'You need to sign in for access to this page.'
    end
  end

end
