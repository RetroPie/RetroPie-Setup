#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

if [ $(id -u) -ne 0 ]; then
  sudo -E "$0"
  exit $?
fi

scriptdir="$(dirname "$0")"
scriptdir="$(cd "$scriptdir" && pwd)"

"$scriptdir/retropie_packages.sh" setup gui

