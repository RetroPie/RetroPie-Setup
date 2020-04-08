#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-uzem"
rp_module_desc="Uzebox engine - Uzem port for libretro"
rp_module_help="ROM Extensions: .uze\n\nCopy your ROM files to $romdir/ports/uzebox"
rp_module_licence="GPL3 https://raw.githubusercontent.com/Uzebox/uzebox/master/gpl-3.0.txt"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-uzem() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-uzem.git
}

function build_lr-uzem() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro -j`nproc`
    md_ret_require="$md_build/uzem_libretro.so"
}

function install_lr-uzem() {
    md_ret_files=(
        'uzem_libretro.so'
    )
}

function configure_lr-uzem() {
    setConfigRoot "ports"

    addPort "$md_id" "uzebox" "Uzebox" "$md_inst/uzem_libretro.so"
    local file="$romdir/ports/Uzebox.sh"

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
done < <( ls -1 $romdir/ports/uzebox )
FILE=\$(dialog --title "List ROMS of directory $romdir/ports/uzebox" --menu "Chose one ROM" 24 80 17 "\${W[@]%.*}" 3>&2 2>&1 1>&3)
if [ "\$FILE" == "" ]; then
    clear
    joy2keyStop   #cancel and back to emulationstation
else
    joy2keyStop
    item=\$((\$FILE*2-1)) 
    "/opt/retropie/supplementary/runcommand/runcommand.sh" 0 _PORT_ "uzebox" "$romdir/ports/uzebox/\${W[\$item]}" #run the game
fi

#END
_EOF_
    chown $user:$user "$file"
    chmod +x "$file"

    mkRomDir "ports/uzebox"
    ensureSystemretroconfig "ports/uzebox"
}
