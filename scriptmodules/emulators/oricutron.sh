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
rp_module_help="ROM Extensions: .dsk .tap\n\nCopy your Oric games to $romdir/oric"
rp_module_licence="GPL2 https://raw.githubusercontent.com/pete-gordon/oricutron/4c359acfb6bd36d44e6d37891d7b6453324faf7d/main.h"
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

function game_data_oricutron() {
    if [[ -d "$md_inst/disks" && ! -f "$romdir/oric/barbitoric.dsk" ]]; then
        # copy demo disks
        cp -v "$md_inst/disks/"* "$romdir/oric/"
        chown -R $user:$user "$romdir/oric"
    fi
}

function configure_oricutron() {
    mkRomDir "oric"

    local machine
    local default
    for machine in atmos oric1 o16k telestrat pravetz; do
        default=0
        [[ "$machine" == "atmos" ]] && default=1
        addEmulator "$default" "$md_id-$machine" "oric" "pushd $md_inst; $md_inst/oricutron --machine $machine %ROM% --fullscreen; popd"
    done
    addSystem "oric"

    [[ "$md_mode" == "install" ]] && game_data_oricutron
}
