#!/usr/bin/env bash

PLAYLISTS=$HOME/Playlists/*
KDECONNECT_ID=57a853f4633b1ea0
KDECONNECT_DIR=/home/kmiyake/.config/kdeconnect/$KDECONNECT_ID/kdeconnect_sftp/$KDECONNECT_ID
KDECONNECT_MUSICDIR=$KDECONNECT_DIR/Music
TMPDIR=/mnt/ostrich/MusicTransfer/

for f in $PLAYLISTS; do
  if [[ ! -d "$KDECONNECT_MUSICDIR" ]]; then
    echo "Error connecting to device; $KDECONNECT_MUSICDIR does not exist"
    exit 1
  else
    cp $f "$KDECONNECT_MUSICDIR/" && echo "copied playlist $f to $KDECONNECT_MUSICDIR/$(basename $f)"
  fi
done
[[ -d "$KDECONNECT_MUSICDIR" ]] && rsync -rvlOz --inplace --size-only --no-perms --progress --delete-before "$TMPDIR" "$KDECONNECT_MUSICDIR/" && echo "rsync finished"

