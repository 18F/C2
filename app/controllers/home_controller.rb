class HomeController < ApplicationController
  before_filter :setup_mygov_client
  before_filter :setup_mygov_access_token

  def oauth_callback
    auth = request.env["omniauth.auth"]
    return_to = session[:return_to]

    reset_session
    session[:user] = auth.extra.raw_info.to_hash
    handle_new_users_from_oauth
    session[:token] = auth.credentials.token
    flash[:success] = "You successfully signed in"
    redirect_to return_to || carts_path
  end

  def index
  end

  def logout
    reset_session
    @current_user = nil
    @mygov_access_token = nil
    redirect_to root_url
  end

private

  def setup_mygov_client
    @mygov_client = OAuth2::Client.new(MYUSA_KEY, MYUSA_SECRET, site: MYUSA_URL, token_url: '/oauth/authorize')
  end

  def setup_mygov_access_token
    if session
      @mygov_access_token = OAuth2::AccessToken.new(@mygov_client, session[:token])
    end
  end

  def handle_new_users_from_oauth
    unless session[:user].blank?
      User.find_or_create_by(email_address: session[:user]['email'])
    end
  end
end
