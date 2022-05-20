FROM ruby:3.1.0-slim

WORKDIR /app
COPY . ./
RUN apt-get update && apt-get install -y ruby-full build-essential && gem install bundler && bundle install


CMD ["bundle", "exec", "ruby", "./script.rb"]