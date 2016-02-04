RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    Test.setup_models
    Rails.application.load_seed
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean
    if Capybara.current_driver != :rack_test
      Rails.application.load_seed
    end
  end

  config.after(:suite) do
    Test.teardown_models
  end
end
