FROM ruby:3.0.0-alpine3.12 AS build

RUN apk add --update --no-cache \
  build-base \
  file \
  less \
  nodejs \
  postgresql-client \
  postgresql-dev \
  tzdata \
  yarn \
  && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
  && adduser --disabled-password --home '/app' app;

WORKDIR /app

USER app

COPY --chown=app:app Gemfile* yarn.lock ./

RUN gem install bundler \
  && bundle \
  && yarn install --force

FROM ruby:3.0.0-alpine3.12 AS dev

RUN apk add --update --no-cache \
  file \
  nodejs \
  postgresql-client \
  tzdata \
  yarn \
  && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
  && adduser --disabled-password --home '/app' app;

WORKDIR /app

USER app

RUN mkdir -p tmp log

COPY --from=build /usr/local/bundle/ /usr/local/bundle/
COPY --from=build --chown=app:app /app/node_modules /app/node_modules
COPY --chown=app:app . .

CMD ["./bin/rails", "s", "-b", "0.0.0.0"]

