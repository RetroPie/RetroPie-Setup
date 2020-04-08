#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-retro8"
rp_module_desc="PICO-8 fantasy console port for libretro"
rp_module_help="ROM Extensions: .p8 .png\n\nCopy your ROM files to $romdir/ports/pico8"
rp_module_licence="GPL3 https://raw.githubusercontent.com/Jakz/retro8/master/LICENSE"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-retro8() {
    local depends=(libsdl2-dev liblua5.3-dev zlib1g-dev)
    getDepends "${depends[@]}"
}

function sources_lr-retro8() {
    gitPullOrClone "$md_build" https://github.com/Jakz/retro8.git
}

function build_lr-retro8() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/retro8_libretro.so"
}

function install_lr-retro8() {
    md_ret_files=(
	'retro8_libretro.so'
	'LICENSE'
    )
}

function configure_lr-retro8() {
    local script
    setConfigRoot "ports"

    addPort "$md_id" "pico8" "PICO-8" "$md_inst/retro8_libretro.so"
    local file="$romdir/ports/PICO-8.sh"

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
done < <( ls -1 $romdir/ports/pico8 )
FILE=\$(dialog --title "List ROMS of directory $romdir/ports/pico8" --menu "Chose one ROM" 24 80 17 "\${W[@]%.*}" 3>&2 2>&1 1>&3)
if [ "\$FILE" == "" ]; then
    clear
    joy2keyStop   #cancel and back to emulationstation
else
    joy2keyStop
    item=\$((\$FILE*2-1)) 
    "/opt/retropie/supplementary/runcommand/runcommand.sh" 0 _PORT_ "pico8" "$romdir/ports/pico8/\${W[\$item]}" #run the game
fi

#END
_EOF_
    chown $user:$user "$file"
    chmod +x "$file"

    mkRomDir "ports/pico8"
    ensureSystemretroconfig "ports/pico8"
}
