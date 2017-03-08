#!/usr/bin/env bash

# options:
# -x do not link files from playlists to temp storage
# -d do not copy files to device
while getopts "dx" arg; do
  case $arg in
    d)
      DEVICE=0
      ;;
    x)
      PL=0
      ;;
    p)
      SPL=0
      ;;
  esac
done

MUSICDIR=/mnt/ostrich/Music/
ALTDIR=$HOME/Music/
PLAYLISTS=$HOME/Playlists/*
KDECONNECT_ID=57a853f4633b1ea0
KDECONNECT_DIR=/home/kmiyake/.config/kdeconnect/$KDECONNECT_ID/kdeconnect_sftp/$KDECONNECT_ID
KDECONNECT_MUSICDIR=$KDECONNECT_DIR/Music
TMPDIR=/mnt/ostrich/MusicTransfer/
LFMSYNC=$HOME/Developer/banshee-lastfm-sync/banshee-lastfm-sync
PLGEN=$HOME/Developer/banshee-playlist-generator/plgen.py

if [[ -e ${LFMSYNC} ]]; then
  echo "Syncing Banshee with LastFM"
  eval "${LFMSYNC}"
else
  echo "Could not locate LastFM sync script"
  exit 1
fi

if [[ -z ${SPL} ]] && [[ -e ${PLGEN} ]]; then
  echo "Generating Static Banshee Smart Playlists"
  eval "${PLGEN}"
else
  echo "Could not locate playlist generator sync script"
  exit 1
fi

if [[ -z ${PL} ]] && ls ${PLAYLISTS} 1> /dev/null 2>&1; then
  echo "Copying from playlists to temp storage"
  rm -rf $TMPDIR
  for f in $PLAYLISTS; do
    echo "Fixing paths in $f"
    sed -i "s,$MUSICDIR,,g" "$f"
    sed -i "s,$ALTDIR,,g" "$f"
    sed -i "s,../Music/,,g" "$f"
    echo "Copying to temporary Music directory"
    rsync -a --link-dest="$TMPDIR" --files-from=$f "$MUSICDIR" "$TMPDIR"
    rsync -a "$f" "$TMPDIR"
    # [[ -e "$KDECONNECT_MUSICDIR/$(basename $f)" ]] && rm "$KDECONNECT_MUSICDIR/$(basename $f)" && echo "removed old playlist $f"
  done
fi

if [[ -z ${DEVICE} ]]; then
  for f in $PLAYLISTS; do
    if [[ ! -d "$KDECONNECT_MUSICDIR" ]]; then
      echo "Error connecting to device; $KDECONNECT_MUSICDIR does not exist"
      exit 1
    else
      cp $f "$KDECONNECT_MUSICDIR/" && echo "copied playlist $f to $KDECONNECT_MUSICDIR/$(basename $f)"
    fi
  done
  [[ -d "$KDECONNECT_MUSICDIR" ]] && rsync -rvlOz --inplace --size-only --no-perms --progress --delete-before "$TMPDIR" "$KDECONNECT_MUSICDIR/" && echo "rsync finished"
fi

