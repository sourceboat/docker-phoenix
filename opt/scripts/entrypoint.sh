#!/usr/bin/env bash
echo "Running entrypoint script..."
set -e
source /etc/bashrc.d/path.sh
source /opt/scripts/startup-commands.sh
exec "$@"
