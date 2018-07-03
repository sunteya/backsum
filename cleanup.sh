#!/usr/bin/env bash

set -e

if [ "$#" == "0" ]; then
  name=$(basename $0)
  echo "Usage: $name KEEP_BACKUPS_COUNT"
  exit 1
fi

keep_backups=$1
if [ "$keep_backups" -lt "1" ]; then
  echo "KEEP_BACKUPS_COUNT must be greater than 0"
  exit 1
fi

ls -r | grep -E '^[[:digit:]]{8}$' | tail -n +$((keep_backups + 1)) | xargs rm -rf
