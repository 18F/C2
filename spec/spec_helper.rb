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

require 'webmock/rspec'
# localhost needed for omniauth
WebMock.disable_net_connect!(allow_localhost: true, allow: 'codeclimate.com:443')

require 'rack_session_access/capybara'

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: false)
end

require 'pundit/rspec'
require 'factory_girl_rails'
require 'site_prism'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include FactoryGirl::Syntax::Methods
  config.raise_errors_for_deprecations!
  config.backtrace_exclusion_patterns << %r{/gems/}
  config.order = :random
end
