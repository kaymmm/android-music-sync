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

