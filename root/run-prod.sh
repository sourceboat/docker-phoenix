#!/usr/bin/env bash
echo "Running via PROD script..."
cd /opt/app

# start application
export PATH="$PATH:./_build/prod/rel/$APP_NAME/bin"
$APP_NAME start
