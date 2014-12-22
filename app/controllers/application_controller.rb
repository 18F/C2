class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :signed_in?

  private

  def current_user
    @current_user ||= User.find_by(email_address: session[:user]['email']) if session[:user]
  end

  def signed_in?
    !!current_user && !session[:user].empty?
  end

  def authenticate_user!
    unless current_user
      session[:return_to] = request.fullpath
      redirect_to root_url, :alert => 'You need to sign in for access to this page.'
    end
  end
end
