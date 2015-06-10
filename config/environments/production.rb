C2::Application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets = true
  config.assets.js_compressor = :uglifier
  config.assets.compile = true
  config.assets.digest = true
  config.assets.version = '1.0'
  config.log_level = :info

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               ENV['SMTP_DOMAIN'] || 'gmail.com',
    user_name:            ENV.fetch('SMTP_USERNAME'),
    password:             ENV.fetch('SMTP_PASSWORD'),
    authentication:       'plain',
    enable_starttls_auto: true
  }

  config.roadie.url_options = config.action_mailer.default_url_options

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
end
