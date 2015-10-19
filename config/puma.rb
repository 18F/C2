# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

workers 1
threads_count = 3
threads threads_count, threads_count

preload_app!

rackup DefaultRackup
port(ENV['PORT'] || 3000)
environment(ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development')

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
