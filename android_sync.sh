#!/usr/bin/env bash

# options:
# -x do not link files from playlists to temp storage
# -s do not sync rhythmbox with lastfm
# -p do not update smart playlists
# -h print usage
while getopts "sxph" arg; do
  case $arg in
    s)
      SY=0
      ;;
    x)
      PL=0
      ;;
    p)
      SPL=0
      ;;
    h)
      echo -e "Usage:\n\tandroid_sync.sh [options]"
      echo -e "Options:"
      echo -e "\t-s\tdo not sync rhythmbox with lastfm"
      echo -e "\t-p\tdo not update smart playlists"
      echo -e "\t-x\tdo not copy files to temp storage"
      echo -e "\t-h\tprint this usage and quit"
      SY=0
      PL=0
      SPL=0
      ;;
  esac
done

MUSICDIR=/mnt/ostrich/Music/
ALTDIR=$HOME/Music/
PLAYLISTS=$HOME/Playlists/*
TMPDIR=/mnt/ostrich/MusicTransfer/
LFMSYNC=$HOME/Developer/rhythmbox-lastfm-sync/sync.py
# RBSYNC=$HOME/Developer/rhythmbox-banshee-metadata-import/import.py
PLGEN=$HOME/Developer/rhythmbox-playlist-generator/plgen.py

if [[ -z ${SY} ]]; then
  if [[ -e ${LFMSYNC} ]]; then
    echo "Syncing Rhythmbox with LastFM"
    eval "${LFMSYNC}"
  else
    echo "Could not locate LastFM sync script"
    exit 1
  fi
fi

if [[ -z ${SPL} ]]; then
  if [[ -e ${PLGEN} ]]; then
    echo "Generating Smart Playlists from Rhythmbox library"
    eval "${PLGEN}"
  else
    echo "Could not locate playlist generator script"
    exit 1
  fi
fi

if [[ -z ${PL} ]]; then
  if ls ${PLAYLISTS} 1> /dev/null 2>&1; then
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
    done
  else
    echo "Could not locate any playlists to copy to temp directory."
  fi
fi

