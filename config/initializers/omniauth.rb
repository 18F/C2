Rails.application.config.middleware.use OmniAuth::Builder do
  MYGOV_CLIENT_ID = ENV['MYGOV_CLIENT_ID']
  MYGOV_SECRET_ID = ENV['MYGOV_SECRET_ID']
  MYGOV_HOME = ENV['MYGOV_HOME']
  SCOPES = ENV['MYGOV_SCOPES']
  provider :myusa, MYGOV_CLIENT_ID, MYGOV_SECRET_ID, :scope => SCOPES, :client_options => {:site => MYGOV_HOME, :token_url => "/oauth/authorize"}
end