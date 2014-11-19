class ApplicationController < ActionController::Base
  before_filter :allow_cors
  protect_from_forgery with: :exception

  helper_method :current_user, :user_signed_in?


  private

  def allow_cors
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"

    if request.method == 'OPTIONS'
      # pre-flight request
      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS#Preflighted_requests
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      # short-circuit the response
      head :ok
    end
  end

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
