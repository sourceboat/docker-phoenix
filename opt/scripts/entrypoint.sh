#!/usr/bin/env bash
echo "Running entrypoint script..."
set -e
source /etc/profile.d/paths.sh
source /opt/scripts/startup-commands.sh
exec "$@"
