source "https://rubygems.org"
ruby "2.3.5" # this should match `.ruby-version` and doc/setup.md
gem "rails", "4.2.7.1"

gem "actionmailer-text", "~> 0.1.1"
gem "active_model_serializers", "~> 0.9.4"
gem "activeadmin", "~> 1.0.0.pre2"
gem "activeadmin_hstore_editor", "0.0.5"
gem "acts_as_list"
gem "acts-as-taggable-on", "~> 3.4"
gem "ahoy_matey", "~> 1.4.0"
gem "aws-sdk-rails"
gem "ar_outer_joins"
gem "autoprefixer-rails"
gem "awesome_print"
gem "aws-sdk", "~> 2.2.15"
gem "browser"
gem "browser-timezone-rails"
gem "blazer"
gem "climate_control"
gem "clockwork", require: false
gem "daemons" # for delayed_job
gem "delayed_job_active_record", "~> 4.1.0"
gem "doorkeeper", "~> 4.2.0"
gem "dotenv-rails", require: "dotenv/rails-now"
gem "draper"
gem "elasticsearch-dsl", "~> 0.1.3"
gem "elasticsearch-model", "~> 0.1.8"
gem "elasticsearch-rails", "~> 0.1.8"
gem "elasticsearch-rails-ha", "~> 1.0.5"
gem "email_reply_parser"
gem "factory_girl_rails"
gem "faker"
gem "foreman", require: false
gem "has_secure_token"
gem "haml"
gem "hashdiff"
gem "html_pipeline_rails"
gem "jquery-rails"
gem "kaminari"
gem "kaminari-bootstrap", "~> 3.0.1"
gem "mandrill-rails"
gem "newrelic_rpm"
gem "omniauth-cg", git: "https://github.com/18F/omniauth-cg"
gem "paper_trail", "~> 4.1.0"
gem "paperclip", "~> 5.2.0"
gem "peek"
gem "peek-delayed_job"
gem "peek-performance_bar"
gem "peek-pg"
gem "pg", "~> 0.18.4"
gem "pry-rails"
gem "pundit", ">= 1.0.0" # Interface for Pundit::NotAuthorizedError changed in this version
gem "rack-cors", require: "rack/cors"
gem "rack-raw-upload"
gem "rake", "11.3.0"
gem "redcarpet"
gem "roadie-rails"
gem "sass-rails", ">= 3.2"
gem "simple_form"
gem "simple_form_object"
gem "sprockets-rails", "< 3" # https://github.com/jfirebaugh/konacha/issues/216
gem "uglifier"
gem "validates_email_format_of"
gem "workflow"

group :development, :production do
  gem "puma"
end

group :test, :development do
  gem "bullet", require: false # use BULLET_ENABLED=true
  gem "database_cleaner"
  gem "konacha"
  # gem "pry-byebug"
  gem "rspec-rails"
  gem "rack_session_access"
end

group :development do
  gem "guard-rspec", require: false
  gem "guard-shell", require: false
  gem "railroady"
  gem "letter_opener"
  gem "letter_opener_web"
  gem "quiet_assets"
  gem "spring"
  gem "spring-commands-rspec"
  gem 'meta_request'
end

group :test do
  gem "addressable"
  gem "capybara"
  gem "codeclimate-test-reporter"
  gem "elasticsearch-extensions"
  gem "fivemat"
  gem "fuubar"
  gem "poltergeist", "~> 1.11.0"
  gem "rspec_junit_formatter"
  gem "shoulda-matchers"
  gem "site_prism"
  gem "test_after_commit"
  gem "timecop"
  gem "webmock", require: false
  gem "zonebie"
end

group :production do
  gem "rails_12factor"
end
