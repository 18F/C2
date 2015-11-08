# https://docs.docker.com/compose/rails/
FROM ruby:2.2.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# https://robots.thoughtbot.com/rails-on-docker
ENV APP_HOME /c2
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME
