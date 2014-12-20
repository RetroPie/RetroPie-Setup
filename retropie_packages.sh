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

rootdir="/opt/retropie"
user=$SUDO_USER
if [ -z "$user" ]
then
    user=$(whoami)
fi
home=$(eval echo ~$user)
romdir="$home/RetroPie/roms"
if [[ ! -d $romdir ]]; then
    mkdir -p $romdir
fi

__ERRMSGS=""
__INFMSGS=""
__doReboot=0

__default_cflags="-O2 -pipe -mfpu=vfp -march=armv6j -mfloat-abi=hard"
__default_asflags=""
__default_makeflags=""
__default_gcc_version="4.7"

[[ -z "${CFLAGS}"        ]] && export CFLAGS="${__default_cflags}"
[[ -z "${CXXFLAGS}" ]] && export CXXFLAGS="${__default_cflags}"
[[ -z "${ASFLAGS}"         ]] && export ASFLAGS="${__default_asflags}"
[[ -z "${MAKEFLAGS}" ]] && export MAKEFLAGS="${__default_makeflags}"

# check, if sudo is used
if [ $(id -u) -ne 0 ]; then
    printf "Script must be run as root. Try 'sudo $0'\n"
    exit 1
fi

# test if we are in a chroot
if [ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]; then
  # make chroot identify as arm6l
  export QEMU_CPU=arm1176
  __chroot=1
else
  __chroot=0
fi

scriptdir=$(dirname $0)
scriptdir=$(cd $scriptdir && pwd)

__swapdir="$scriptdir/tmp/"

source "$scriptdir/scriptmodules/helpers.sh"
source "$scriptdir/scriptmodules/packages.sh"

rps_checkNeededPackages git dialog gcc-4.7 g++-4.7

# set default gcc version
gcc_version $__default_gcc_version

registerAllModules

[[ "$1" == "init" ]] && return

# load RetronetPlay configuration
source "$scriptdir/configs/retronetplay.cfg"

# ID scriptmode
if [[ $# -eq 1 ]]; then
    ensureRootdirExists
    rp_callModule $1

# ID Type mode
elif [[ $# -eq 2 ]]; then
    ensureRootdirExists
    rp_callModule $1 $2

# show usage information
else
    rp_printUsageinfo
fi

if [[ ! -z $__ERRMSGS ]]; then
    echo $__ERRMSGS >&2
fi

if [[ ! -z $__INFMSGS ]]; then
    echo $__INFMSGS
fi

