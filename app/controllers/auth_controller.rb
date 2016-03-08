class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:oauth_callback, :failure]
  skip_before_action :check_disabled_client

  def oauth_callback
    auth = request.env["omniauth.auth"]
    return_to_path = fetch_return_to_path
    begin
      try_user_auth(auth, return_to_path)
    rescue EmailRequired => error
      Rails.logger.error(error)
      render :failure, status: 400
    end
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
    if return_to_struct && return_to_struct.key?("path")
      return_to_struct[:path]
    end
  end

  def do_user_auth(auth)
    sign_out
    user = User.from_oauth_hash(auth)
    sign_in(user)
  end

  def try_user_auth
    do_user_auth(auth)
    session[:token] = auth.credentials.token
    flash[:success] = "You successfully signed in"
    redirect_to return_to_path || proposals_path
  end
end
