#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

declare -i EXIT_CODE=0

# Simple bash color plate for log statements.
purple='\033[0;34m'
green='\033[1;92m'
red='\033[0;31m'
end='\033[0m'

# Simple log functions for failure, success, and info's messages
info() { echo -e "[${purple}i${end}] $1"; }
failure() { echo -e "[${red}✘${end}] $1"; }
success() { echo -e "[${green}✔︎${end}] $1"; }

if [ $# -eq 0 ]
  then
    failure "No app name supplied. Use this script like: ${purple}./setup.sh my_awesome_app'${end}."
    failure "Exiting now."
    exit 1
fi

app_name=$1

# Checks that docker and docker-compose are available.
if ! command -v docker &> /dev/null
then
    failure "COULD NOT find ${red}docker${end} command!"
    exit 1
elif ! command -v docker-compose &> /dev/null
then
    failure "COULD NOT find ${red}docker-compose${end} command!"
    exit 1
fi

docker run --rm -it -v ${PWD}:/${app_name} ruby:3.0.0-alpine3.12 \
  apk add build-base \
          file \
          git \
          less \
          nodejs \
          openssh \
          postgresql-client \
          postgresql-dev \
          tzdata \
          yarn; \
  gem install rails; \
  # Using wget until thor is able  ready for ruby 3
  wget https://raw.githubusercontent.com/FloHeinle/rails-template/main/composer.rb; \
  rails new ${app_name} -m composer.rb -d postgresql --webpack=stimulus;

cd ${app_name}
chmod +x script/setup.sh script/wait-for-postgres.sh;
./script/setup.sh
docker-compose stop

success "Build successfully!"
