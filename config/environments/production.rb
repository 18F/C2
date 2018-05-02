C2::Application.configure do
  config.action_controller.perform_caching = true
  config.action_mailer.delivery_method = :ses_mail_delivery
  config.action_mailer.asset_host = AppParamCredentials.asset_host
  config.active_support.deprecation = :notify
  config.assets.compile = true
  config.assets.digest = true
  config.assets.js_compressor = :uglifier
  config.assets.version = "1.0"
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.eager_load = true
  config.i18n.fallbacks = true
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :info
  config.roadie.url_options = config.action_mailer.default_url_options
  config.serve_static_files = true
end
