FROM ruby:2.3

ENV app /app
RUN mkdir $app
WORKDIR $app

ENV BUNDLE_PATH /box

ADD . $app

CMD rails s -b 0.0.0.0
