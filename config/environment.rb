# Load the Rails application.
require File.expand_path('../application', __FILE__)

#Load all commands
require "#{Rails.root}/app/commands/base"
require "#{Rails.root}/app/commands/approval/initiate_cart_approval.rb"

# Initialize the Rails application.
C2::Application.initialize!
