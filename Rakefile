# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

C2::Application.load_tasks

desc 'Run the test suite'
# RSpec task gets included automatically
# http://stackoverflow.com/a/28886514/358804
task default: 'konacha:run'

desc 'One time active beta launch'
task :activate_global_beta => :environment do
  count = 0
  non_beta_users =  User.select{|u| !u.roles.map(&:name).include?('beta_user')}
  non_beta_users.each do |user|
    user.add_role('beta_user')
    user.add_role('beta_active')
    print "."
    count += 1
  end
  puts "\n"
  puts "#{count} users were made active beta users"
end
