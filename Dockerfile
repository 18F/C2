FROM ruby:2.3.1
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  nodejs-legacy \
  npm
RUN npm install -g phantomjs-prebuilt
RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install
RUN gem install foreman
RUN curl https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh > /usr/local/bin/wait-for-it
RUN chmod +x /usr/local/bin/wait-for-it
CMD wait-for-it db:5432 && bundle exec rake dev:prime && \
  foreman start
