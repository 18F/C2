ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require "shoulda/matchers"
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/support/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.include ControllerSpecHelper, type: :controller
  config.include FeatureSpecHelper, type: :feature
  config.include RequestSpecHelper, type: :request

  [:feature, :request].each do |type|
    config.include IntegrationSpecHelper, type: type
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    Rails.application.load_seed
  end

  config.before(:each) do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :truncation
    end

    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    ActionMailer::Base.deliveries.clear
    OmniAuth.config.mock_auth[:myusa] = nil
    # only need to re-load seeds if the cleaner used truncation
    if Capybara.current_driver != :rack_test
      Rails.application.load_seed
    end
  end

  Capybara.default_host = 'http://localhost:3000'
  OmniAuth.config.test_mode = true
  ENV["DISABLE_SANDBOX_WARNING"] = "true"
end
