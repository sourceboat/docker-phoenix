# docker-phoenix

[![Docker Build Status](https://img.shields.io/docker/cloud/build/sourceboat/docker-phoenix.svg?style=flat-square)](https://hub.docker.com/r/sourceboat/docker-phoenix/builds/)
[![Release](https://img.shields.io/github/release/sourceboat/docker-phoenix.svg?style=flat-square)](https://github.com/sourceboat/docker-phoenix/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/sourceboat/docker-phoenix.svg?style=flat-square)](https://hub.docker.com/r/sourceboat/docker-phoenix/)
[![Image Size](https://img.shields.io/docker/image-size/sourceboat/docker-phoenix?style=flat-square)](https://microbadger.com/images/sourceboat/docker-phoenix)
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/sourceboat/docker-phoenix.svg?style=flat-square)](https://microbadger.com/images/sourceboat/docker-phoenix)

An opinionated docker image which aims to be perfectly suited to run our Phoenix applications.

## What's included?

### Images for Development and Production

This project contains two Docker image variants:

- `<version>-builder` is based on an up-to-date version of the official `elixir:<x.x.x>-alpine` image and contains additional dependencies to develop and release a Phoenix application.
- `<version>-runtime` is based on an up-to-date version of the  official `alpine:<x.x.x>` image and contains just the minimal tools to run an Elixir release.

In addition to the specific versions there are `latest` (based on the `main` branch) and `edge` (based on the `develop` branch) version tags available.

**Note:** You can check the [`Dockerfile`](Dockerfile) or the [releases page](https://github.com/sourceboat/docker-phoenix/releases) for info on the current versions of Elixir and Alpine.

### Additional Startup Commands

You can add environment varialbles to run additional commands on container startup via the `STARTUP_COMMAND_<XXX>` syntax.
This is useful for installing dependencies in development (see usage example below) or running database migrations in simple production setups.

## Usage

You can use this `Dockerfile` as a starting point and adjust it to your needs:

```Dockerfile
########################################################################
# Stage: builder
########################################################################

FROM sourceboat/docker-phoenix:<version>-builder as builder

ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY package.json yarn.lock ./
RUN yarn install --pure-lockfile

COPY webpack.mix.js tailwind.config.js ./
COPY assets assets/
COPY lib/my_app_web/templates lib/my_app_web/templates/
COPY lib/my_app_web/views lib/my_app_web/views/
RUN yarn prod

COPY . .

########################################################################
# Stage: release
########################################################################

FROM builder as release

ENV MIX_ENV=prod

RUN mix do deps.get, deps.compile, phx.digest, release --overwrite

########################################################################
# Stage: runtime
########################################################################

FROM sourceboat/docker-phoenix:<version>-runtime as runtime

ENV MIX_ENV=prod \
    RELEASE_NAME=my_app

COPY --from=release --chown=nobody:nobody /opt/app/_build /opt/app/_build
COPY --from=release --chown=nobody:nobody /opt/app/priv /opt/app/priv

USER nobody:nobody
```

For local development you can use the following `docker-compose.yml` file:

```yml
version: '3.7'
services:
  app:
    build:
      context: .
      target: builder
      args:
        MIX_ENV: dev
    env_file: .env
    environment:
      - STARTUP_COMMAND_1=mix deps.get
      - STARTUP_COMMAND_2=yarn install --pure-lockfile
    volumes:
      - .:/opt/app:delegated
    ports:
      - "4000:4000"
  postgres:
    image: postgres:12-alpine
    environment:
      - POSTGRES_PASSWORD=postgres
    ports:
      - 54321:5432
```

## Changelog

Check [releases](https://github.com/sourceboat/docker-phoenix/releases) for all notable changes.

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
