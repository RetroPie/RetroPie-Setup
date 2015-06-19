#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
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
source "$scriptdir/scriptmodules/packages.sh"

setup_env

if ! getDepends git dialog wget gcc-$__default_gcc_version g++-$__default_gcc_version build-essential xmlstarlet; then
    printMsgs "console" "Unable to install packages required by $0" "${md_ret_errors[@]}" >&2
    exit 1
fi

# if joy2key is installed run it with a default configuration in background with axis mapps to cursor
# keys and first two buttons mapped to enter and space
if [[ -f "$rootdir/supplementary/joy2key/bin/joy2key" ]] && ! pgrep joy2key; then
    "$rootdir/supplementary/joy2key/bin/joy2key" -terminal -thresh 0 0 0 0 -axis 0x1b5b44 0x1b5b43 0x1b5b41 0x1b5b42  -buttons 0x0a 0x20 >/dev/null & 
    __joy2key_pid=$!
fi

# set default gcc version
gcc_version "$__default_gcc_version"

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
    kill $__joy2key_pid
fi
