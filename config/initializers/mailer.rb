# needs to be set up after DEFAULT_URL_HOST is defined in env_check

if Rails.env.production?
  default_scheme = 'https'
  default_port = nil
else
  default_scheme = 'http'
  default_port = 3000
end

C2::Application.config.action_mailer.default_url_options ||= {
  scheme: ENV['DEFAULT_URL_SCHEME'] || default_scheme,
  host: DEFAULT_URL_HOST,
  port: ENV['DEFAULT_URL_PORT'] || default_port
}
