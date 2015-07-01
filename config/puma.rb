# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

workers Integer(ENV['WEB_CONCURRENCY'] || 1)
threads_count = Integer(ENV['MAX_THREADS'] || 5) # should match database.yml
threads threads_count, threads_count

preload_app!

rackup DefaultRackup
port(ENV['PORT'] || 3000)
environment(ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development')

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection

  # https://github.com/Tomohiro/plate/commit/0a5a072c8d882f32a48d8bdbfa325e83719f58f8
  require 'newrelic_rpm'
  NewRelic::Agent.manual_start
end
