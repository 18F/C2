ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rails/test_help'
require 'simplecov'
require 'steps/user_steps'
require 'steps/approval_steps'
require 'integration_spec_helper'
SimpleCov.start 'rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir.glob("./spec/steps/**/*steps.rb") { |f| load f, true }

RSpec.configure do |config|
  #Add modules for Turnip acceptance tests
  config.include UserSteps
  config.include ApprovalSteps

  #Add modules for helpers
  config.include IntegrationSpecHelper

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Configs for database_cleaner gem
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  Capybara.default_host = 'http://localhost:3000'
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:myusa, {
    :raw_info => {"name"=>"George Jetson"},
    :uid => '12345',
    :nickname => 'georgejetsonmyusa'
  })

end
