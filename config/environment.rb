# Load the Rails application.
require File.expand_path("../application", __FILE__)

# Initialize the Rails application.
C2::Application.initialize!

C2::Application.configure do
  config.logger = Logger.new(STDOUT)
end
