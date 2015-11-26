#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

# global variables ==========================================================

# main retropie install location
rootdir="/opt/retropie"

user="$SUDO_USER"
[[ -z "$user" ]] && user=$(id -un)

home="$(eval echo ~$user)"
datadir="$home/RetroPie"
biosdir="$datadir/BIOS"
romdir="$datadir/roms"
emudir="$rootdir/emulators"
configdir="$rootdir/configs"

scriptdir=$(dirname "$0")
scriptdir=$(cd "$scriptdir" && pwd)

__logdir="$scriptdir/logs"
__tmpdir="$scriptdir/tmp"
__builddir="$__tmpdir/build"
__swapdir="$__tmpdir"

# check, if sudo is used
if [[ $(id -u) -ne 0 ]]; then
    echo "Script must be run as root. Try 'sudo $0'"
    exit 1
fi

__backtitle="PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user"

source "$scriptdir/scriptmodules/system.sh"
source "$scriptdir/scriptmodules/helpers.sh"
source "$scriptdir/scriptmodules/inifuncs.sh"
source "$scriptdir/scriptmodules/packages.sh"

setup_env

# if joy2key.py is installed run it with cursor keys for axis, and enter + space for buttons 0 and 1
__joy2key_dev=$(ls -1 /dev/input/js* 2>/dev/null | head -n1)
if [[ -f "$rootdir/supplementary/runcommand/joy2key.py" && -n "$__joy2key_dev" ]] && ! pgrep -f joy2key.py >/dev/null; then
    "$rootdir/supplementary/runcommand/joy2key.py" "$__joy2key_dev" 1b5b44 1b5b43 1b5b41 1b5b42 0a 20 & 2>/dev/null
    __joy2key_pid=$!
fi

mkUserDir "$romdir"
mkUserDir "$biosdir"

rp_registerAllModules

ensureFBMode 320 240

[[ "$1" == "init" ]] && return

if [[ $# -gt 0 ]]; then
    ensureRootdirExists
    rp_callModule "$@"
else
    rp_printUsageinfo
fi

printMsgs "console" "${__INFMSGS[@]}"

if [[ -n $__joy2key_pid ]]; then
    kill -INT $__joy2key_pid 2>/dev/null
fi
