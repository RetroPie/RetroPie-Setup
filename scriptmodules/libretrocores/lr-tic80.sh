#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-tic80"
rp_module_desc="TIC-80 Tiny Computer port for libretro"
rp_module_help="ROM Extensions: .tic\n\nCopy your ROM files to $romdir/ports/tic80"
rp_module_licence="MIT https://raw.githubusercontent.com/nesbox/TIC-80/master/LICENSE"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-tic80() {
    local depends=(cmake build-essential libgtk-3-dev libsdl2-dev liblua5.3-dev zlib1g-dev)
    getDepends "${depends[@]}"
}

function sources_lr-tic80() {
    gitPullOrClone "$md_build" https://github.com/nesbox/TIC-80.git
}

function build_lr-tic80() {
    cd "$md_build/build"
    make clean
    cmake .. -DBUILD_PLAYER=OFF -DBUILD_SOKOL=OFF \
    -DBUILD_SDL=OFF -DBUILD_DEMO_CARTS=OFF -DBUILD_LIBRETRO=ON
    make -j`nproc`
    md_ret_require="$md_build/build/lib/tic80_libretro.so"
}

function install_lr-tic80() {
    md_ret_files=(
        'build/lib/tic80_libretro.so'
    )
}

function configure_lr-tic80() {
    local script
    setConfigRoot "ports"

    addPort "$md_id" "tic80" "TIC-80" "$md_inst/tic80_libretro.so"
    local file="$romdir/ports/TIC-80.sh"

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
done < <( ls -1 $romdir/ports/tic80 )
FILE=\$(dialog --title "List ROMS of directory $romdir/ports/tic80" --menu "Chose one ROM" 24 80 17 "\${W[@]%.*}" 3>&2 2>&1 1>&3)
if [ "\$FILE" == "" ]; then
    clear
    joy2keyStop   #cancel and back to emulationstation
else
    joy2keyStop
    item=\$((\$FILE*2-1)) 
    "/opt/retropie/supplementary/runcommand/runcommand.sh" 0 _PORT_ "tic80" "$romdir/ports/tic80/\${W[\$item]}" #run the game
fi

#END
_EOF_
    chown $user:$user "$file"
    chmod +x "$file"

    mkRomDir "ports/tic80"
    ensureSystemretroconfig "ports/tic80"
}
