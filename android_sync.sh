#!/usr/bin/env bash

# Copyright 2016, 2017 Keith Miyake
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

while getopts "sxpch" arg; do
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
    c)
      COP=0
      ;;
    h)
      echo -e "Usage:\n\tandroid_sync.sh [options]"
      echo -e "Options:"
      echo -e "\t-s\tdo not sync rhythmbox with lastfm"
      echo -e "\t-p\tdo not update smart playlists"
      echo -e "\t-x\tdo not copy files to temp storage"
      echo -e "\t-c\tcall KDE Connect copy script after copying files"
      echo -e "\t-h\tprint this usage and quit"
      SY=0
      PL=0
      SPL=0
      ;;
  esac
done

# get the script's directory
# see: https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# set remaining paths accordingly
MUSICDIR=$HOME/Music/
PLAYLISTS=$HOME/Playlists/*
TMPDIR=$HOME/MusicTransfer/
LFMSYNC=$DIR/lib/rhythmbox-lastfm-sync/sync.py
PLGEN=$DIR/lib/rhythmbox-playlist-generator/plgen.py
KDECSCRIPT=$DIR/kdeconnect_sync.sh

if [[ -z ${SY} ]]; then
  if [[ -e ${LFMSYNC} ]]; then
    echo "Syncing Rhythmbox with LastFM"
    eval "python3 ${LFMSYNC}"
  else
    echo "Could not locate LastFM sync script"
    exit 1
  fi
fi

if [[ -z ${SPL} ]]; then
  if [[ -e ${PLGEN} ]]; then
    echo "Generating Smart Playlists from Rhythmbox library"
    eval "python3 ${PLGEN}"
  else
    echo "Could not locate playlist generator script"
    exit 1
  fi
fi

if [[ -z ${PL} ]]; then
  if ls ${PLAYLISTS} 1> /dev/null 2>&1; then
    echo "Copying from playlists to temp storage"
    rm -rf $TMPDIR/*
    # mkdir $TMPDIR
    for f in $PLAYLISTS; do
      echo "Fixing paths in $f"
      sed -i "s,$MUSICDIR,,g" "$f"
      sed -i "s,../Music/,,g" "$f"
      echo "Copying to temporary Music directory"
      rsync -a "$f" "$TMPDIR"
      sed -e '/^#/d' -e "s|^\(.*\)$|$MUSICDIR\1|g" -e 's| |\ |g' -e 's|/|\/|g' "$f" | xargs -d '\n' -i{} ln -f {} "$TMPDIR"
    done
  else
    echo "Could not locate any playlists to copy to temp directory."
  fi
fi

if [[ -n ${COP} ]]; then
  if [[ -e ${KDECSCRIPT} ]]; then
    eval "source ${KDECSCRIPT}"
  fi
fi

