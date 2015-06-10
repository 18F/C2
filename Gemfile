source 'https://rubygems.org'

gem 'active_model_serializers'
gem 'acts_as_list'
gem 'ar_outer_joins'
gem 'autoprefixer-rails'
gem 'awesome_print'
gem 'aws-sdk-v1'    # remaining on v1 due to https://github.com/thoughtbot/paperclip/issues/1764
gem 'bootstrap-sass', '~> 3.3.0'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'draper'
gem 'factory_girl_rails'
gem 'faker'
gem 'font-awesome-sass'
gem 'haml'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'newrelic_rpm'
gem 'omniauth-myusa', git: 'https://github.com/18F/omniauth-myusa.git'
gem "paperclip"
gem 'pg'
gem 'pundit'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-ssl-enforcer'
gem 'rails', '~> 4.1.8'
gem 'redcarpet'
gem 'roadie-rails'
gem 'sass-rails', '>= 3.2'
gem 'simple_form_object'
gem 'turbolinks'
gem 'uglifier'
gem 'workflow'

group :test, :development do
  gem 'bullet'
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
