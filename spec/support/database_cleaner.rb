RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
    Role.ensure_system_roles_exist
    Test.setup_models
    Rails.application.load_seed
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, js: true) do
    # :truncation is slow and conservative
    # :transaction is fast and more aggressive
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    Proposal.clear_index_tracking
    DatabaseCleaner.clean
  end
end
