FROM alpine:latest

#Install Base
RUN apk update
RUN apk upgrade
RUN apk add curl wget bash

#Install Dev Dependencies
RUN apk add gcc g++ libpng-dev make libxslt-dev libxml2-dev zlib-dev sqlite-dev

#Install ruby, rdoc, and dev kit
RUN apk add ruby ruby-rdoc ruby-dev

#Install Git
RUN apk add git

#Install Sqlite3
RUN apk add sqlite sqlite-dev

# Clean APK cache
RUN rm -rf /var/cache/apk/*

RUN mkdir /usr/app
WORKDIR /usr/app

#Copy Gemfile and install Gems
COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN gem install bundler
RUN bundle install

COPY . /usr/app

CMD ["/usr/app/bot.rb"]

