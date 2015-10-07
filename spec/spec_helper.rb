require 'codeclimate-test-reporter'
SimpleCov.start 'rails' do
  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter
  ]

  if ENV['CIRCLE_ARTIFACTS']
    dir = File.join(ENV['CIRCLE_ARTIFACTS'], 'coverage')
    coverage_dir(dir)
  end
end

require 'zonebie'
Zonebie.set_random_timezone

require 'rack_session_access/capybara'

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

require 'pundit/rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.raise_errors_for_deprecations!
  config.backtrace_exclusion_patterns << %r{/gems/}
  config.order = :random
end
