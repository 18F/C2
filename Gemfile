source 'https://rubygems.org'

gem 'active_model_serializers'
gem 'acts_as_list'
gem 'ar_outer_joins'
gem 'autoprefixer-rails'
gem 'awesome_print'
gem 'bootstrap-sass', '~> 3.3.0'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'draper'
gem 'font-awesome-sass'
gem 'haml'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'newrelic_rpm'
gem 'omniauth-myusa', git: 'https://github.com/18F/omniauth-myusa.git'
gem 'pg'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 4.1.8'
gem 'roadie-rails'
gem 'sass-rails', '>= 3.2'
gem 'simple_form_object'
gem 'turbolinks'
gem 'uglifier'
gem 'workflow'
gem 'factory_girl_rails'
gem 'faker'

group :test, :development do
  gem 'database_cleaner'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rack_session_access'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'mail_view'
  gem 'railroady'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'spring'
  gem 'spring-commands-rspec'

  # Capistrano stuff
  gem 'aws-sdk', '2.0.6.pre', require: false
  gem 'capistrano', require: false
  gem 'capistrano-ec2_tagged', require: false
end

group :test do
  gem 'addressable'
  gem 'capybara'
  gem 'codeclimate-test-reporter'
  gem "poltergeist"
  gem 'simplecov'
  gem 'timecop'
  gem 'turnip'

  # For better test reporting in CircleCI
  # http://blog.circleci.com/announcing-detailed-test-failure-reporting/
  # with a fix from
  # https://github.com/circleci/rspec_junit_formatter/pull/4
  gem 'rspec_junit_formatter', git: 'https://github.com/amitree/rspec_junit_formatter.git', ref: '33a0fdd'
end

group :production do
  gem 'rails_12factor'
end
