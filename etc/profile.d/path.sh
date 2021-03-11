#!/usr/bin/env bash
# add elixir release path to $PATH
if [[ -n "$RELEASE_NAME" ]]; then 
  export PATH="$PATH:/opt/app/_build/prod/rel/$RELEASE_NAME/bin"
fi
