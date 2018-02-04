#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rom="$1"

rootdir="/opt/retropie"
datadir="$HOME/RetroPie"
romdir="$datadir/roms/amiga"
savedir="$romdir"
biosdir="$datadir/BIOS"
kickfile="$biosdir/kick13.rom"

source "$rootdir/lib/archivefuncs.sh"

if [[ ! -f "$kickfile" ]]; then
    dialog --no-cancel --pause "You need to copy the Amiga kickstart file (kick13.rom) to the folder $biosdir to boot the Amiga emulator." 22 76 15
    exit 1
fi

archiveExtract "$rom" ".adf .adz .dms .ipf"

# check successful extraction and if we have at least one file
if [[ $? == 0 ]]; then
    rom="${arch_files[0]}"
    romdir="$arch_dir"

    floppy_images=()
    for i in "${!arch_files[@]}"; do
        floppy_images+=("--floppy_image_$i=${arch_files[$i]}")
    done
fi

fs-uae --floppy_drive_0="$rom" "${floppy_images[@]}" --kickstart_file="$kickfile" --floppies_dir="$romdir" --save_states_dir="$savedir"
archiveCleanup
