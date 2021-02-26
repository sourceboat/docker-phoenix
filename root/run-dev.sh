#!/usr/bin/env bash
echo "Running via DEV script..."
cd /opt/app

# install dependencies
mix deps.get
yarn install --pure-lockfile

# start the phoenix server
mix phx.server
