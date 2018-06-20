#!/usr/bin/env bash

set -e

if [ "$#" == "0" ]; then
  name=$(basename $0)
  echo "Usage: $name [OPTIONS]... [USER@]HOST:SRC [:SRC]..."
  echo "Please see the rsync man pages for full documentation."
  exit 1
fi

basename=$(date +%Y%m%d)
curr=$basename.processing

if [ -e $basename  ]; then
  rm -rf $curr
  mv $basename $curr
fi

prev=$(ls -r | grep -v "$curr" | grep -v -E '\.processing$' | grep -E '^[[:digit:]]{8}' | head -1)


rsync_args=(--archive --verbose --delete --relative --owner --group --perms)
if [ -n "$prev" ]; then
  prev_path=$(realpath $prev)
  rsync_args+=("--link-dest=$prev_path")
fi

rsync_args+=("$@")
rsync_args+=($curr)

rsync ${rsync_args[@]}

mv $curr $basename

