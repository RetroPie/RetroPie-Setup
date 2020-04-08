#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-chailove"
rp_module_desc="2D Game Framework with ChaiScript roughly inspired by the LÖVE API to libretro"
rp_module_help="ROM Extension: .chai .chailove\n\nCopy your ChaiLove games to $romdir/ports/chailove"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/libretro-chailove/master/COPYING"
rp_module_section="exp"

function sources_lr-chailove() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-chailove.git
}

function build_lr-chailove() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/chailove_libretro.so"
}

function install_lr-chailove() {
    md_ret_files=(
        'chailove_libretro.so'
    )
}

function configure_lr-chailove() {
    setConfigRoot "ports"

    addPort "$md_id" "chailove" "ChaiLove" "$md_inst/chailove_libretro.so" 
    local file="$romdir/ports/ChaiLove.sh"

    cat >"$file" << _EOF_
#!/bin/bash

scriptdir="\$HOME/RetroPie-Setup"
source "\$scriptdir/scriptmodules/helpers.sh"

joy2keyStart
let i=0 
W=() 
while read -r line; do
    let i=\$i+1
    W+=(\$i "\$line")
done < <( ls -1 $romdir/ports/chailove )
FILE=\$(dialog --title "List ROMS of directory $romdir/ports/chailove" --menu "Chose one ROM" 24 80 17 "\${W[@]%.*}" 3>&2 2>&1 1>&3)
if [ "\$FILE" == "" ]; then
    clear
    joy2keyStop   #cancel and back to emulationstation
else
    joy2keyStop
    item=\$((\$FILE*2-1)) 
    "/opt/retropie/supplementary/runcommand/runcommand.sh" 0 _PORT_ "chailove" "$romdir/ports/chailove/\${W[\$item]}" #run the game
fi

#END
_EOF_
    chown $user:$user "$file"
    chmod +x "$file"

    mkRomDir "ports/chailove"

    ensureSystemretroconfig "ports/chailove"
}
