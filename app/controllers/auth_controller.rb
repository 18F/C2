class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:oauth_callback, :failure]
  skip_before_action :check_disabled_client

  def oauth_callback
    auth = request.env["omniauth.auth"]
    return_to_path = fetch_return_to_path
    begin
      try_user_auth(auth, return_to_path)
    rescue EmailRequired => error
      Rails.logger.error("Unsuccessful login: #{error}")
      render :failure, status: 200
    end
    Rails.logger.info("Successful login: #{auth.info}")
  end

  def failure
  end

  def logout
    sign_out
    redirect_to root_url
  end

  protected

  def fetch_return_to_path
    return_to_struct = return_to
    return_to_struct[:path] if return_to_struct && return_to_struct.key?("path")
  end

  def send_welcome_mail(user)
    if (Time.current - user.created_at) < 2.seconds
      WelcomeMailer.welcome_notification(user).deliver_later
    end
  end

  def try_user_auth(auth, return_to_path)
    do_user_auth(auth)
    session[:token] = auth.credentials.token
    flash[:success] = "You are now signed in."
    redirect_to return_to_path || proposals_path
  end

  def do_user_auth(auth)
    sign_out
    user = User.from_oauth_hash(auth)
    send_welcome_mail(user) if AppConfigCredentials.welcome_email
    sign_in(user)
  end
end
