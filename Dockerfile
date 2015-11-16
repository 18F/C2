# https://docs.docker.com/compose/rails/
FROM ruby:2.2.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# https://robots.thoughtbot.com/rails-on-docker
ENV APP_HOME /c2
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

# https://github.com/18F/C2/pull/730#discussion_r43045350
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD . $APP_HOME

ENV PORT 3000

CMD $APP_HOME/bin/rake db:setup && $APP_HOME/script/start
