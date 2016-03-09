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

  Capybara.default_host = 'http://localhost:3000'
  OmniAuth.config.test_mode = true
  ENV["DISABLE_SANDBOX_WARNING"] = "true"
end
