source 'https://rubygems.org'

gem 'acts_as_list'
gem 'autoprefixer-rails'
gem 'awesome_print'
gem 'bootstrap-sass', '~> 3.3.0'
gem 'dotenv-rails'
gem 'draper'
gem 'font-awesome-sass'
gem 'haml'
gem 'jquery-rails'
gem 'omniauth-myusa', git: 'https://github.com/18F/omniauth-myusa.git'
gem 'pg'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 4.1.7'
gem 'roadie', '~> 2.4'
gem 'sass-rails', '>= 3.2'
gem 'settingslogic'
gem 'simple_form_object'
gem 'turbolinks'
gem 'uglifier'
gem 'newrelic_rpm'

group :test, :development do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'mail_view'
  gem 'railroady'

  # Capistrano stuff
  gem 'aws-sdk', '2.0.6.pre', require: false
  gem 'capistrano', require: false
  gem 'capistrano-ec2_tagged', require: false
end

group :test do
  gem 'addressable'
  gem 'capybara'
  gem 'codeclimate-test-reporter'
  gem 'simplecov'
  gem 'turnip'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
