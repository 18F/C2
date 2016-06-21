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
    # :truncation is slow and conservative
    # :transaction is fast and aggressive
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    ActionMailer::Base.deliveries.clear
    Proposal.clear_index_tracking
    DatabaseCleaner.clean
    Rails.application.load_seed if Capybara.current_driver != :rack_test
  end

  config.after(:suite) do
    Test.teardown_models
  end
end
