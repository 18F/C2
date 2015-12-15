ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require "shoulda/matchers"
require "elasticsearch/extensions/test/cluster"
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

def create_es_index(klass)
  errors = []
  completed = 0
  puts "Creating Index for class #{klass}"
  klass.__elasticsearch__.create_index! force: true, index: klass.index_name
  klass.__elasticsearch__.refresh_index!
  klass.__elasticsearch__.import  :return => 'errors', :batch_size => 200    do |resp|
    # show errors immediately (rather than buffering them)
    errors += resp['items'].select { |k, v| k.values.first['error'] }
    completed += resp['items'].size
    puts "Finished #{completed} items"
    STDERR.flush
    STDOUT.flush
    if errors.size > 0
      STDOUT.puts "ERRORS in #{$$}:"
      STDOUT.puts pp(errors)
    end
  end
  puts "Completed #{completed} records of class #{klass}"
end

def start_es_server
  # circleci has locally installed version of elasticsearch so alter PATH to find
  ENV["PATH"] = "./elasticsearch-1.7.4/bin:#{ENV["PATH"]}"

  es_test_cluster_opts = {
    nodes: 1,
    path_logs: "tmp/es-logs"
  }

  unless Elasticsearch::Extensions::Test::Cluster.running?
    Elasticsearch::Extensions::Test::Cluster.start(es_test_cluster_opts)
  end

  # create index(s) to test against.
  create_es_index(Proposal)
end

def stop_es_server
  if Elasticsearch::Extensions::Test::Cluster.running?
    Elasticsearch::Extensions::Test::Cluster.stop
  end
end

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
    start_es_server unless ENV['ES_SKIP']
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

  config.after(:suite) do
    stop_es_server unless ENV['ES_SKIP']
  end

  Capybara.default_host = 'http://localhost:3000'
  OmniAuth.config.test_mode = true
  ENV["DISABLE_SANDBOX_WARNING"] = "true"
end
