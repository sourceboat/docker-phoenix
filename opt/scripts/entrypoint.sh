#!/usr/bin/env bash
echo "Running entrypoint script..."
set -e
source /etc/profile.d/path.sh
source /opt/scripts/startup-commands.sh
exec "$@"
