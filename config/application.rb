require File.expand_path('../boot', __FILE__)
require 'rails/all'
require 'elasticsearch/rails/instrumentation'

Bundler.require(:default, Rails.env)

module C2
  class Application < Rails::Application
    # https://git.io/ETVYsQ
    config.middleware.insert_before 0, Rack::Cors, logger: Rails.logger do
      allow do
        origins '*'

        resource "/api/*",
          headers: :any,
          methods: [:get, :post, :delete, :put, :options, :head],
          max_age: 1728000
      end
    end

    config.middleware.use Rack::Attack

    config.force_ssl = Rails.env.production?

    config.action_mailer.raise_delivery_errors = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml')]
    config.roadie.url_options = config.action_mailer.default_url_options
    config.autoload_paths << Rails.root.join('app', 'mailers', 'concerns')
    config.autoload_paths << Rails.root.join('app', 'policies', 'concerns')
    config.autoload_paths << Rails.root.join('lib')
    config.middleware.use "Rack::RawUpload"
    # remove for Rails 4.3+(?)
    config.active_record.raise_in_transactional_callbacks = true
    config.active_job.queue_adapter = :delayed_job
  end
end
