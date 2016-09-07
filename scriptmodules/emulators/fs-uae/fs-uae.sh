#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

ROM="$1"

rootdir="/opt/retropie"
configdir="$rootdir/configs"
config="$configdir/amiga/default_cfg.fs-uae"

user="$SUDO_USER"
[[ -z "$user" ]] && user=$(id -un)
home="$(eval echo ~$user)"
datadir="$home/RetroPie"
romdir="$datadir/roms"
biosdir="$datadir/BIOS"
kickfile="$biosdir/kick13.rom"

if [[ -f "$kickfile" ]]; then
    fs-uae "$config" --floppy_drive_0="$ROM" --kickstart_file="$kickfile" --floppies_dir="$romdir/amiga" --save_states_dir="$romdir/amiga"
else
    dialog --msgbox "You need to copy the Amiga kickstart file (kick13.rom) to the folder $biosdir to boot the Amiga emulator." 22 76
fi

