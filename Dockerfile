FROM ruby:4

WORKDIR /app
COPY Gemfile* /app

RUN gem install debug
RUN bundle install


