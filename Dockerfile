FROM ruby:3.1.0
WORKDIR /app
COPY Gemfile* ./
RUN gem install bundler && bundle install

COPY . ./

CMD ["bundle", "exec", "ruby", "./script.rb"]