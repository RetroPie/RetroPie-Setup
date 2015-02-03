#!/usr/bin/env bash

#
#  (c) Copyright 2012-2014  Florian Müller (contact@petrockblock.com)
#
#  RetroPie-Setup homepage: https://github.com/petrockblog/RetroPie-Setup
#
#  Permission to use, copy, modify and distribute this work in both binary and
#  source form, for non-commercial purposes, is hereby granted without fee,
#  providing that this license information and copyright notice appear with
#  all copies and any derived work.
#
#  This software is provided 'as-is', without any express or implied
#  warranty. In no event shall the authors be held liable for any damages
#  arising from the use of this software.
#
#  RetroPie-Setup is freeware for PERSONAL USE only. Commercial users should
#  seek permission of the copyright holders first. Commercial use includes
#  charging money for RetroPie-Setup or software derived from RetroPie-Setup.
#
#  The copyright holders request that bug fixes and improvements to the code
#  should be forwarded to them so everyone can benefit from the modifications
#  in future versions.
#
#  Many, many thanks go to all people that provide the individual packages!!!
#

# global variables ==========================================================

# main retropie install location
rootdir="/opt/retropie"

user="$SUDO_USER"
[[ -z "$user" ]] && user=$(id -un)

home="$(eval echo ~$user)"
biosdir="$home/RetroPie/BIOS"
romdir="$home/RetroPie/roms"
emudir="$rootdir/emulators"
configdir="$rootdir/configs"

scriptdir=$(dirname "$0")
scriptdir=$(cd "$scriptdir" && pwd)

__tmpdir="$scriptdir/tmp"
__builddir="$__tmpdir/build"
__swapdir="$__tmpdir"

# check, if sudo is used
if [[ $(id -u) -ne 0 ]]; then
    echo "Script must be run as root. Try 'sudo $0'"
    exit 1
fi

source "$scriptdir/scriptmodules/system.sh"
source "$scriptdir/scriptmodules/helpers.sh"
source "$scriptdir/scriptmodules/packages.sh"

setup_env

getDepends git dialog python-lxml gcc-$__default_gcc_version g++-$__default_gcc_version build-essential

# set default gcc version
gcc_version $__default_gcc_version

mkUserDir "$romdir"
mkUserDir "$biosdir"

rp_registerAllModules

[[ "$1" == "init" ]] && return

if [[ $# -gt 0 ]]; then
    ensureRootdirExists
    rp_callModule "$@"
else
    rp_printUsageinfo
fi

if [[ -n $__ERRMSGS ]]; then
    echo $__ERRMSGS >&2
fi

if [[ -n $__INFMSGS ]]; then
    echo $__INFMSGS
fi

