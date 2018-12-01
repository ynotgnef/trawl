FROM ruby:2.5.1-alpine3.7

RUN apk --update --no-cache add --virtual build-dependencies ruby-dev build-base git && \
    gem sources --remove https://rubygems.org/ && \
    gem install bundler --source https://rubygems.org --no-ri --no-rdoc

ADD Gemfile /app/

RUN cd /app/ && \
    bundle install --jobs 2 --without development test && \
    apk del build-dependencies

ADD . /app

WORKDIR /app

ENV P_PROCESSES='' \
    P_THREADS=''

CMD ruby momentum.rb