#!/usr/bin/env bash
echo "Running entrypoint script..."

set -e

export PATH="$PATH:/opt/app/_build/prod/rel/$APP_NAME/bin"

# TODO: generic startup commands

exec "$@"
