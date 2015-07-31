source 'https://rubygems.org'
ruby '2.2.2' # this should match `.ruby-version` and docs/setup.md

gem 'active_model_serializers'
gem 'acts_as_list'
gem 'ar_outer_joins'
gem 'autoprefixer-rails'
gem 'awesome_print'
gem 'aws-sdk-v1'    # remaining on v1 due to https://github.com/thoughtbot/paperclip/issues/1764
gem 'bootstrap-sass'
gem 'clockwork', require: false
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'draper'
gem 'factory_girl_rails'
gem 'faker'
gem 'font-awesome-sass'
gem 'foreman', require: false
gem 'haml'
gem 'html_pipeline_rails'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'newrelic_rpm'
gem 'omniauth-myusa', git: 'https://github.com/18F/omniauth-myusa.git'
gem 'paperclip'
gem 'paper_trail'
gem 'peek'
gem 'peek-performance_bar'
gem 'peek-pg'
gem 'pg'
gem 'puma'
gem 'pundit', '>= 1.0.0'  # Interface for Pundit::NotAuthorizedError changed in this version
gem 'rack-cors', require: 'rack/cors'
gem 'rack-ssl-enforcer'
gem 'rails'
gem 'redcarpet'
gem 'roadie-rails'
gem 'sass-rails', '>= 3.2'
gem 'simple_form_object'
gem 'turbolinks'
gem 'uglifier'
gem 'workflow'

group :test, :development do
  gem 'bullet', require: false # use BULLET_ENABLED=true
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
  gem 'rspec_junit_formatter'
end

group :production do
  gem 'rails_12factor'
end
