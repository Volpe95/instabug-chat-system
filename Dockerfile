FROM ruby:3.1.2

RUN apt-get update

RUN apt-get install -y --no-install-recommends mariadb-server

RUN apt-get install -y --no-install-recommends default-mysql-server default-libmysqlclient-dev \
  build-essential patch ruby-dev zlib1g-dev liblzma-dev \
  curl
  
# RUN rm -rf /var/lib/apt/lists/*
#Adding cron 
RUN apt-get update && apt-get install -y cron
RUN apt-get update && \
  apt-get install -qq -y --no-install-recommends cron && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . .


# RUN apk del build_deps
ENV RAILS_ENV production

EXPOSE 3000
