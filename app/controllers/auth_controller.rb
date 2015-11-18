class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:oauth_callback]

  def oauth_callback
    auth = request.env["omniauth.auth"]
    return_to_path = fetch_return_to_path
    do_user_auth(auth)
    session[:token] = auth.credentials.token
    flash[:success] = "You successfully signed in"
    redirect_to return_to_path || proposals_path
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
end
