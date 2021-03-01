#!/usr/bin/env bash
echo "Running entrypoint script..."
set -e
export PATH="$PATH:/opt/app/_build/prod/rel/$RELEASE_NAME/bin"
source /opt/scripts/startup-commands.sh
exec "$@"
