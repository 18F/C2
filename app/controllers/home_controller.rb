class HomeController < ApplicationController
  before_filter :setup_session_user
  before_filter :reset_session, :only => [:start]
  # before_filter :merge_params_to_session
  before_filter :setup_mygov_client
  before_filter :setup_mygov_access_token

  def oauth_callback
    auth = request.env["omniauth.auth"]
    session[:user] = auth.extra.raw_info.to_hash
    session[:token] = auth.credentials.token
    redirect_to session[:return_to] || root_url
  end

  def index
  end

  def logout
    session[:user] = nil # :before_filter sets to empty hash
    redirect_to root_url
  end

  private

  def setup_session_user
    session[:user] = {} if session[:user].nil?
  end

  def setup_mygov_client
    @mygov_client = OAuth2::Client.new(ENV['MYGOV_CLIENT_ID'], ENV['MYGOV_SECRET_ID'], {:site => ENV['MYGOV_HOME'], :token_url => "/oauth/authorize"})
  end

  def setup_mygov_access_token
    @mygov_access_token = OAuth2::AccessToken.new(@mygov_client, session[:token]) if session
  end

  def merge_params_to_session
    session.deep_merge!(params)
  end


  # >>>>>>>>>>>>>>>.
  # FOR REFERENCE:
  # >>>>>>>>>>>>>>>
  def store_form_data
    form_number = 'ss-5' if session[:reasons][:married].present?
    form_number = '79960' if session[:reasons][:court_order].present?
    body = {}
    body.merge!(:form_number => form_number)
    body.merge!(:data => session[:user])
    @mygov_access_token.post("/api/forms", :body => body)
  end

  def create_tasks
    task_items = []
    task_items << {:name => 'Get a new Social Security card', :url => 'http://www.socialsecurity.gov/online/ss-5.pdf'} if session[:reasons][:married].present?
    task_items << {:name => 'Renew your passport', :url => 'http://www.state.gov/documents/organization/79960.pdf'} if session[:reasons][:court_order].present?
    tasks_response = @mygov_access_token.post("/api/tasks", :params => {:task => {:name => 'Change your name', :task_items_attributes => task_items}})
    JSON.parse(tasks_response.body)
  end
end