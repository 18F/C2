ENV["RAILS_ENV"] ||= "test"

require "spec_helper"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "shoulda/matchers"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

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

  Capybara.default_host = "http://localhost:3000"
  OmniAuth.config.test_mode = true

  config.before(:each) do
    Role.ensure_system_roles_exist
  end
end

# Increase speed by minimizing I/O through reduced logging
Rails.logger.level = 4

if false
# Hack by Jose Valim for all threads to share one DB connection This works on Capybara
# because it starts the web server in a thread.
# http://blog.plataformatec.com.br/2011/12/three-tips-to-improve-the-performance-of-your-test-suite/
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
end
