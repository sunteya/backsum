#!/usr/bin/env bash

set -e
# set -x

backup_dir=$PWD

name=$(basename $0)
command=${1:-usage}
shift || true

list(){
  ls -r "$backup_dir" | grep -E '^[[:digit:]]{8}-?'
}

cleanup(){
  if [ "$#" == "0" ] || [ "$1" == "help" ]; then
    name=$(basename $0)
    echo "Usage: $name $command KEEP_BACKUPS_COUNT"
    exit 1
  fi

  keep_backups=$1
  if [ "$keep_backups" -lt "1" ]; then
    echo "KEEP_BACKUPS_COUNT must be greater than 0"
    exit 1
  fi

  outdated_list=$(list | grep -E '^[[:digit:]]{8}$' | tail -n +$((keep_backups + 1)))
  for name in $outdated_list; do
    echo "remove $name"
    rm -rf "$backup_dir/$name"
  done
}

perform(){
  if [ "$#" == "0" ] || [ "$1" == "help" ]; then
    echo "Usage: $name $command [OPTIONS]... [USER@]HOST:SRC [:SRC]..."
    echo "Please see the rsync man pages for full documentation."
    exit 1
  fi

  name=$(date +%Y%m%d)
  echo "start new backup to $backup_dir/$name"

  name_processing=$name.processing

  if [ -e "$backup_dir/$name" ]; then
    rm -rf "$backup_dir/$name_processing"
    mv "$backup_dir/$name" "$backup_dir/$name_processing"
  elif [ -e "$backup_dir/MIRROR" ]; then
    rm -rf "$backup_dir/$name_processing"
    mv "$backup_dir/MIRROR" "$backup_dir/$name_processing"
  else
    name_previous=$(list | grep -v '\.processing$' | head -1)
  fi

  rsync_opts=(--archive --verbose --delete --relative)
  if [ -n "$name_previous" ]; then
    previous_path=$(realpath "$backup_dir/$name_previous")
    rsync_opts+=("--link-dest=$previous_path")
  fi

  rsync_args=("$@")
  rsync_args+=("$backup_dir/$name_processing")

  # Try twice to fix symbolic link error
  rsync "${rsync_opts[@]}" "${rsync_args[@]}" || rsync "${rsync_opts[@]}" --no-perms "${rsync_args[@]}"

  mv "$backup_dir/$name_processing" "$backup_dir/$name"
  ls -r "$backup_dir" | grep -E '^[[:digit:]]{8}\.processing$' | xargs rm -rf
  echo "backup success"
}

usage() {
  echo "Usage: $name <COMMAND> [ARGS]..."
  echo "Available commands are:"
  echo "   perform    begin a new backup."
  echo "   cleanup    cleanup outdated backups."
  echo "   list       list all backups."
}

case "$command" in
  perform) perform "$@" ;;
  cleanup) cleanup "$@" ;;
  list) list "$@" ;;
  *) usage ;;
esac
