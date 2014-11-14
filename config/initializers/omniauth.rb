MYGOV_CLIENT_ID = ENV.fetch('MYGOV_CLIENT_ID')
MYGOV_SECRET_ID = ENV.fetch('MYGOV_SECRET_ID')
MYGOV_HOME = ENV.fetch('MYGOV_HOME')

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :myusa, MYGOV_CLIENT_ID, MYGOV_SECRET_ID, {
    scope: 'profile.email',
    client_options: {
      site: MYGOV_HOME,
      token_url: "/oauth/authorize"
    }
  }
end
