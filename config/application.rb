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

    config.before_configuration do
      ['environment_variables.yml','feature_flags.yml'].each do |filename|
        env_file = Rails.root.join("config", filename).to_s

        if File.exist?(env_file)
          YAML.load_file(env_file)[Rails.env].each do |key, value|
            ENV[key.to_s] = value
          end
        end
      end
    end

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

    config.exceptions_app = self.routes

    config.autoload_paths << Rails.root.join('lib')

  end
end
