Rails.application.config.middleware.use OmniAuth::Builder do
  MYGOV_CLIENT_ID = '52342c76fc91fff9bfe4488789b214b487470f16840287611b6f73e9086413f6' #  ENV['MYGOV_CLIENT_ID']
  MYGOV_SECRET_ID = '4a24a336b6f879cf7586a7596ed7b5b525b674015dbb6313356ac539d81a531c' #ENV['MYGOV_SECRET_ID']
  MYGOV_HOME =  'https://myusa-staging.18f.us' #   ENV['MYGOV_HOME']
  SCOPES = 'profile.email profile.first_name profile.last_name' #ENV['MYGOV_SCOPES']
  provider :myusa, MYGOV_CLIENT_ID, MYGOV_SECRET_ID, :scope => SCOPES, :client_options => {:site => MYGOV_HOME, :token_url => "/oauth/authorize"}
end