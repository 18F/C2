FROM ruby:2.3.3

RUN apt-get update
RUN apt-get install nodejs -y

ENV workdir /app
RUN mkdir -p $workdir
WORKDIR $workdir

ADD Gemfile $workdir/Gemfile
ADD Gemfile.lock $workdir/Gemfile.lock
ENV BUNDLE_PATH /box
RUN bundle check || bundle install

RUN mkdir -p tmp/pids


#RUN bin/rake "dev:prime[admin@gsa.gov]"
#RUN bin/rake "populate:ncr:for_user[admin@gsa.gov]"
