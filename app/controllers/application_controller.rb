class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :signed_in?

  private

  def current_user
    User.find_by(email_address: session[:user]['email']) if session[:user].present?
  end

  def signed_in?
    !!current_user
  end

  def authenticate_user!
    unless current_user
      session[:return_to] = request.fullpath
      redirect_to root_url, :alert => 'You need to sign in for access to this page.'
    end
  end
end
