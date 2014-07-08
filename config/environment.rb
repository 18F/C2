# Load the Rails application.
require File.expand_path('../application', __FILE__)

require "#{Rails.root}/app/commands/base"
require "#{Rails.root}/app/commands/approval/update_from_approval_response.rb"

# Initialize the Rails application.
C2::Application.initialize!
