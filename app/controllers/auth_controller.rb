class AuthController < ApplicationController
  before_action :setup_mygov_access_token

  def oauth_callback
    auth = request.env["omniauth.auth"]

    do_user_authn(auth)

    session[:token] = auth.credentials.token
    flash[:success] = "You successfully signed in"
    redirect_to return_to_path || proposals_path
  end

  def logout
    sign_out
    @mygov_access_token = nil
    redirect_to root_url
  end

  protected

  def mygov_client
    @mygov_client ||= OAuth2::Client.new(MYUSA_KEY, MYUSA_SECRET, site: MYUSA_URL, token_url: "/oauth/authorize")
  end

  def setup_mygov_access_token
    if session
      @mygov_access_token = OAuth2::AccessToken.new(self.mygov_client, session[:token])
    end
  end

  def return_to_path
    return_to_struct = return_to
    if return_to_struct && return_to_struct.key?("path")
      return_to_struct[:path]
    end
  end

  def do_user_authn(auth)
    sign_out
    user = User.from_oauth_hash(auth)
    sign_in(user)
  end
end
