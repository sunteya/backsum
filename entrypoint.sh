#!/usr/bin/env bash

if [ -d /mnt/user/.ssh ]; then
  cp -r /mnt/user/.ssh /root/.ssh
fi

exec "$@"