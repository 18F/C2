class HomeController < ApplicationController
  before_filter :setup_session_user
  before_filter :setup_mygov_client
  before_filter :setup_mygov_access_token

  def oauth_callback
    auth = request.env["omniauth.auth"]
    return_to = session[:return_to]

    reset_session
    session[:user] = auth.extra.raw_info.to_hash
    session[:token] = auth.credentials.token
    flash[:success] = "You successfully signed in"
    redirect_to return_to || root_url
  end

  def index
  end

  def logout
    reset_session
    @mygov_access_token = nil
    redirect_to root_url
  end

private

  def setup_session_user
    session[:user] ||= {}
  end

  def setup_mygov_client
    @mygov_client = OAuth2::Client.new(MYGOV_CLIENT_ID, MYGOV_SECRET_ID, site: MYGOV_HOME, token_url: '/oauth/authorize')
  end

  def setup_mygov_access_token
    if session
      @mygov_access_token = OAuth2::AccessToken.new(@mygov_client, session[:token])
    end
  end
end
