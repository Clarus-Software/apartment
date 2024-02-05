FROM ruby:3.2.1

# Add postgres 12 repo
RUN apt-get update -qq && apt-get install -y lsb-release && apt-get clean all
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

#Install packages
RUN apt-get update -qq && apt-get install -y postgresql-client-12 libpq-dev nodejs default-mysql-client

RUN mkdir -p /app

# Set working directory
WORKDIR /app

# Adding gems
COPY APARTMENT_VERSION APARTMENT_VERSION
COPY Gemfile Gemfile
COPY ros-apartment.gemspec ros-apartment.gemspec
# COPY Gemfile.lock Gemfile.lock
RUN gem install bundler:2.5.5
RUN bundle install

# Adding project files
COPY . .
