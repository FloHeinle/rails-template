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

COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build

docker-compose run --rm web sh -c 'bundle install' || true
docker-compose run --rm web sh -c './script/wait-for-postgres.sh postgres postgres bin/rails db:create db:migrate'
docker-compose run --rm webpack sh -c 'yarn install' || true
