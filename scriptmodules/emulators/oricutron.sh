#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="oricutron"
rp_module_desc="Oricutron Oric 1/Oric Atmos emulator"
rp_module_help="ROM Extension: .dsk .tap\n\nCopy your Oric roms to $romdir/oric"
rp_module_section="exp"

function depends_oricutron() {
    local depends=(cmake libsdl2-dev)
    isPlatform "x11" && depends+=(libgtk-3-dev)
    getDepends "${depends[@]}"
}

function sources_oricutron() {
    gitPullOrClone "$md_build" https://github.com/HerbFargus/oricutron.git extras
}

function build_oricutron() {
    make clean
    if isPlatform "rpi" || isPlatform "mali"; then
        make PLATFORM=rpi SDL_LIB=sdl2
    else
        make SDL_LIB=sdl2
    fi
}

function install_oricutron() {
    md_ret_files=(
        'oricutron'
        'oricutron.cfg'
        'roms'
        'disks'
        'images'
    )
}

function configure_oricutron() {
    mkRomDir "oric"

    # copy demo disks
    cp -v "$md_inst/disks/"* "$romdir/oric/"
    chown -R $user:$user "$romdir/oric"
    
    local machine
    local default
    for machine in atmos oric1 o16k telestrat pravetz; do
        default=0
        [[ "$machine" == "atmos" ]] && default=1
        addSystem 1 "$md_id-$machine" "oric" "pushd $md_inst; $md_inst/oricutron --machine $machine %ROM% --fullscreen; popd" "Oric 1/Atmos" ".dsk .tap"
    done
}
