source 'https://rubygems.org'
ruby '2.2.3' # this should match `.ruby-version` and docs/setup.md

gem 'active_model_serializers'
gem 'activeadmin', github: 'activeadmin'
gem 'acts_as_list'
gem 'acts-as-taggable-on', '~> 3.4'
gem 'ar_outer_joins'
gem 'autoprefixer-rails'
gem 'awesome_print'
gem 'aws-sdk', '~> 1.6' # version restriction can be lifted once https://github.com/thoughtbot/paperclip/commit/523bd46c768226893f23889079a7aa9c73b57d68 is released
gem 'bootstrap-sass'
gem 'browser-timezone-rails'
gem 'climate_control'
gem 'clockwork', require: false
gem 'daemons' # for delayed_job
gem 'delayed_job_active_record'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'draper'
gem 'email_reply_parser'
gem 'factory_girl_rails'
gem 'faker'
gem 'font-awesome-sass'
gem 'foreman', require: false
gem "has_secure_token"
gem 'haml'
gem 'hashdiff'
gem 'html_pipeline_rails'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'mandrill-rails'
gem 'newrelic_rpm'
# oauth2 gem locked hard at pre-1.4.0 because 1.4.0 breaks. 
# See comments on https://github.com/intridea/omniauth-oauth2/commit/26152673224aca5c3e918bcc83075dbb0659717f
gem 'omniauth-oauth2', '1.3.1'
gem 'omniauth-myusa', git: 'https://github.com/18F/omniauth-myusa.git'
gem 'paper_trail'
gem 'paperclip'
gem 'peek'
gem 'peek-delayed_job'
gem 'peek-performance_bar'
gem 'peek-pg'
gem 'pg'
gem 'puma'
gem 'pundit', '>= 1.0.0'  # Interface for Pundit::NotAuthorizedError changed in this version
gem 'rack-cors', require: 'rack/cors'
gem 'rails'
gem 'redcarpet'
gem 'roadie-rails'
gem 'sass-rails', '>= 3.2'
gem 'simple_form'
gem 'simple_form_object'
gem 'turbolinks'
gem 'uglifier'
gem 'validates_email_format_of'
gem 'workflow'

group :test, :development do
  gem 'bullet', require: false # use BULLET_ENABLED=true
  gem 'database_cleaner'
  gem 'konacha'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rack_session_access'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'guard-shell', require: false
  gem 'mail_view'
  gem 'railroady'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'quiet_assets'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'addressable'
  gem 'capybara'
  gem 'codeclimate-test-reporter'
  gem 'poltergeist'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'timecop'
  gem 'webmock', require: false
  gem 'zonebie'

  # For better test reporting in CircleCI
  # http://blog.circleci.com/announcing-detailed-test-failure-reporting/
  gem 'rspec_junit_formatter'
end

group :production do
  gem 'rails_12factor'
end
