class HomeController < ApplicationController
  before_filter :setup_mygov_client
  before_filter :setup_mygov_access_token
  # just to cut down on exception spam
  before_action :authenticate_user!, only: :error

  def oauth_callback
    auth = request.env["omniauth.auth"]
    return_to = self.return_to.try(:path)

    sign_out
    user = User.from_oauth_hash(auth)
    sign_in(user)

    session[:token] = auth.credentials.token
    flash[:success] = "You successfully signed in"
    redirect_to return_to || proposals_path
  end

  def index
  end

  def error
    raise "test exception"
  end

  def logout
    sign_out
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
end
