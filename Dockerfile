FROM ruby:3.3

RUN apt-get update && apt-get install -y gnuplot && apt-get clean \
       && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile* /app

RUN gem install debug
RUN bundle install


