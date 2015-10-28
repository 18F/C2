# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

C2::Application.load_tasks

desc 'Run the test suite'
# RSpec task gets included automatically
# http://stackoverflow.com/a/28886514/358804
task default: 'konacha:run'
