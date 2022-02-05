#!/usr/bin/env python

# Copyright 2016, 2022 Keith Miyake
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

# Combined Android Playlist Sync:
#   Sync LastFM -> Rhythmbox
#   Create Smart Playlists
#   (Formerly copied files to transfer directory)
# v1.0.0
# 2022-02-05

import argparse
from lib.rhythmbox_lastfm_sync import sync
from lib.rhythmbox_playlist_generator import plgen

VERSION = "1.0.0"

parser = argparse.ArgumentParser(
    usage="%(prog)s [OPTIONS]",
    description="Sync LastFM and Create Smart Playlists via Rhythmbox"
)
parser.add_argument(
    "-v", "--version", action="version",
    version = f"{parser.prog} " + VERSION,
    help = 'print version and quit'
)

parser.add_argument('-s', action='store_false', dest='s',
    help='Do not sync LastFM scrobbles to Rhythmbox.'
)
parser.add_argument('-p', action='store_false', dest='p',
    help='Do not creat/update smart playlists.'
)

args = parser.parse_args()

if args.s:
    sync.sync_lastfm()

if args.p:
    plgen.generate_playlists()
