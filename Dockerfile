FROM ruby:2.3.5

RUN apt-get update
RUN apt-get install nodejs -y

ENV workdir /app
RUN mkdir -p $workdir
WORKDIR $workdir

ADD Gemfile $workdir/Gemfile
ADD Gemfile.lock $workdir/Gemfile.lock
# ENV BUNDLE_PATH /box
RUN bundle install
COPY . $workdir

RUN mkdir -p tmp/pids

# RUN bundle exec rake "dev:prime[admin@gsa.gov]"
# RUN bundle exec rake "populate:ncr:for_user[admin@gsa.gov]"
