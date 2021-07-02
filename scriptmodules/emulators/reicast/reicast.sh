#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

AUDIO="$1"
ROM="$2"
XRES="$3"
YRES="$4"
rootdir="/opt/retropie"
configdir="$rootdir/configs"
biosdir="$HOME/RetroPie/BIOS/dc"

source "$rootdir/lib/inifuncs.sh"

if [[ ! -f "$biosdir/dc_boot.bin" ]]; then
    dialog --no-cancel --pause "You need to copy the Dreamcast BIOS files (dc_boot.bin and dc_flash.bin) to the folder $biosdir to boot the Dreamcast emulator." 22 76 15
    exit 1
fi

params=(-config config:homedir=$HOME -config x11:fullscreen=1)
[[ -n "$XRES" ]] && params+=(-config x11:width=$XRES -config x11:height=$YRES)
[[ -n "$AUDIO" ]] && params+=(-config audio:backend=$AUDIO -config audio:disable=0)
[[ -n "$ROM" ]] && params+=(-config config:image="$ROM")
if [[ "$AUDIO" == "oss" ]]; then
    aoss "$rootdir/emulators/reicast/bin/reicast" "${params[@]}"
else
    "$rootdir/emulators/reicast/bin/reicast" "${params[@]}"
fi
