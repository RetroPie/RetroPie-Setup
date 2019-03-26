#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="quake3"
rp_module_desc="Quake 3"
rp_module_licence="GPL2 https://raw.githubusercontent.com/raspberrypi/quake3/master/COPYING.txt"
rp_module_section="opt"
rp_module_flags="!x86 !mali !kms"

function depends_quake3() {
    getDepends libsdl1.2-dev libraspberrypi-dev
}

function sources_quake3() {
    gitPullOrClone "$md_build" https://github.com/raspberrypi/quake3.git
}

function build_quake3() {
    ./build_rpi_raspbian.sh
}

function install_quake3() {
    md_ret_files=(
        'build/release-linux-arm/ioq3ded.arm'
        'build/release-linux-arm/ioquake3.arm'
    )
}

function game_data_quake3() {
    if [[ ! -f "$romdir/ports/quake3/pak0.pk3" ]]; then
        downloadAndExtract "$__archive_url/Q3DemoPaks.zip" "$romdir/ports/quake3" -j
    fi
    # always chown as moveConfigDir in the configure_ script would move the root owned demo files
    chown -R $user:$user "$romdir/ports/quake3"
}

function configure_quake3() {
    addPort "$md_id" "quake3" "Quake III Arena" "LD_LIBRARY_PATH=lib $md_inst/ioquake3.arm"

    mkRomDir "ports/quake3"

    moveConfigDir "$md_inst/baseq3" "$romdir/ports/quake3"

    # Add user for no sudo run
    usermod -a -G video $user

    [[ "$md_mode" == "install" ]] && game_data_quake3
}
