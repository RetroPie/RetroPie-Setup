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

# this function takes one argument like "/home/vbs/RetroPie/roms/amiga/0-B/Barbarian II (1991)(Psygnosis)[cr FLT](Disk 1 of 2).adf"
# then it finds all files that start with the same prefix "/home/vbs/RetroPie/roms/amiga/0-B/Barbarian II (1991)(Psygnosis)[cr FLT](Disk"
# if the initial filename does not contain "(Disk" then it returns just the initial file
function getFiles() {
    DIR=$(dirname "$1")
    BASE=$(basename "$1")
    PATTERN=$(echo "$BASE" | sed s/\(Disk.*/\(Disk/g)
    find "$DIR" | grep -F "$PATTERN" | sort
}

FLOPPYIMAGES=()
n=0
while read i
do
    FLOPPYIMAGES+=("--floppy_image_$n=$i")
    (( n += 1))
done < <(getFiles "$ROM")

if [[ -f "$kickfile" ]]; then
    fs-uae "$config" --floppy_drive_0="$ROM" "${FLOPPYIMAGES[@]}" --kickstart_file="$kickfile" --floppies_dir="$romdir/amiga" --save_states_dir="$romdir/amiga"
else
    dialog --msgbox "You need to copy the Amiga kickstart file (kick13.rom) to the folder $biosdir to boot the Amiga emulator." 22 76
fi

