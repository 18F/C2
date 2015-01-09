MYUSA_KEY = ENV.fetch('MYUSA_KEY')
MYUSA_SECRET = ENV.fetch('MYUSA_SECRET')
MYUSA_URL = ENV['MYUSA_URL'] || 'https://myusa.18f.us'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :myusa, MYUSA_KEY, MYUSA_SECRET, {
    scope: 'profile.email',
    client_options: {
      site: MYUSA_URL,
      token_url: "/oauth/authorize"
    }
  }
end
