require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module C2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # http://git.io/ETVYsQ
    config.middleware.insert_before 0, Rack::Cors, logger: Rails.logger do
      allow do
        origins '*'

        resource '*',
          headers: :any,
          methods: [:get, :post, :delete, :put, :options, :head],
          max_age: 1728000
      end
    end

    config.middleware.use(Rack::SslEnforcer) if ENV['FORCE_HTTPS'] == 'true'

    config.action_mailer.raise_delivery_errors = true

    config.action_mailer.default_url_options = {
      scheme: ENV['DEFAULT_URL_SCHEME'] || 'http',
      host: ENV['HOST_URL'] || ENV['DEFAULT_URL_HOST'] || 'localhost',
      port: ENV['DEFAULT_URL_PORT'] || 3000
    }
    config.roadie.url_options = config.action_mailer.default_url_options

    config.autoload_paths << Rails.root.join('lib')

    config.assets.precompile << 'common/communicarts.css'

    # Paperclip's attachment settings are determined by S3 env vars
    if ENV['S3_BUCKET_NAME'] && ENV['S3_ACCESS_KEY_ID'] && ENV['S3_SECRET_ACCESS_KEY']
      Paperclip::Attachment.default_options.merge!(
        bucket: ENV['S3_BUCKET_NAME'],
        s3_credentials: {
          access_key_id: ENV['S3_ACCESS_KEY_ID'],
          secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
        },
        s3_permissions: :private,
        storage: :s3,
      )
    end
  end
end
