#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-lutro"
rp_module_desc="Lua engine - lua game framework (WIP) for libretro following the LÖVE API"
rp_module_help="ROM Extensions: .lutro .lua"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/libretro-lutro/master/LICENSE"
rp_module_section="exp"

function sources_lr-lutro() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-lutro.git
}

function build_lr-lutro() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/lutro_libretro.so"
}

function install_lr-lutro() {
    md_ret_files=(
	'lutro_libretro.so'
    )
}

function configure_lr-lutro() {
    local script
    setConfigRoot "ports"

    addPort "$md_id" "lutro" "Lutro" "$md_inst/lutro_libretro.so"
    local file="$romdir/ports/Lutro.sh"

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
done < <( ls -1 $romdir/ports/lutro )
FILE=\$(dialog --title "List ROMS of directory $romdir/ports/lutro" --menu "Chose one ROM" 24 80 17 "\${W[@]%.*}" 3>&2 2>&1 1>&3)
if [ "\$FILE" == "" ]; then
    clear
    joy2keyStop   #cancel and back to emulationstation
else
    joy2keyStop
    item=\$((\$FILE*2-1)) 
    "/opt/retropie/supplementary/runcommand/runcommand.sh" 0 _PORT_ "lutro" "$romdir/ports/lutro/\${W[\$item]}" #run the game
fi

#END
_EOF_
    chown $user:$user "$file"
    chmod +x "$file"

    mkRomDir "ports/lutro"
    ensureSystemretroconfig "ports/lutro"
}
