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

    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               ENV.fetch('SMTP_DOMAIN'),
      user_name:            ENV.fetch('SMTP_USERNAME'),
      password:             ENV.fetch('SMTP_PASSWORD'),
      authentication:       'plain',
      enable_starttls_auto: true
    }

    config.exceptions_app = self.routes

    config.autoload_paths << Rails.root.join('app/forms')
    config.autoload_paths << Rails.root.join('lib')
  end
end
