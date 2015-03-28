#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

# =============================================================
#  START OF THE MAIN SCRIPT
# =============================================================

scriptdir=$(dirname "$0")
scriptdir=$(cd "$scriptdir" && pwd)

# check, if sudo is used
if [[ $(id -u) -ne 0 ]]; then
    echo "Script must be run as root. Try 'sudo $0'"
    exit 1
fi

"$scriptdir/retropie_packages.sh" setup

