#!/usr/bin/env bash
echo "Running via DEV script..."
cd $HOME

# install dependencies
mix deps.get
yarn install --pure-lockfile

# start the phoenix server
mix phx.server
