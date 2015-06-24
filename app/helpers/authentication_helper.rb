module AuthenticationHelper
  extend ActiveSupport::Concern

  included do
    protected

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
  end
end
