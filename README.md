# A very opinionated rails-template

## What it does

Creates a new dockerized rails application. Preconfigured with:

- ruby 3
- rails (latest)
- docker image
- docker-compose setup
- postgresql
- stimulus
- webpacker-dev-server

## Prerequisites

[docker](https://docs.docker.com/get-docker/)

[docker-compose](https://docs.docker.com/compose/install/)

## Usage

### Option 1: pipe into shell

```sh
bash <( curl https://raw.githubusercontent.com/FloHeinle/rails-template/main/setup.sh ) name-of-your-rails-app
```

### Option 2: git clone

```sh
chmod +x setup.sh
./setup.sh name-of-your-rails-app
```

Credits to [dao42](https://github.com/dao42/rails-template)
