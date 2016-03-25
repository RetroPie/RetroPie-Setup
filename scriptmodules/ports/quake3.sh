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
rp_module_menus="2+"
rp_module_flags="!x86 !mali"

function depends_quake3() {
    getDepends libsdl1.2-dev libraspberrypi-dev
}

function sources_quake3() {
    gitPullOrClone "$md_build" https://github.com/raspberrypi/quake3.git
    sed -i "s#/opt/bcm-rootfs##g" build.sh
    sed -i "s/^CROSS_COMPILE/#CROSS_COMPILE/" build.sh
}

function build_quake3() {
    ./build.sh
}

function install_quake3() {
    md_ret_files=(
        'build/release-linux-arm/ioq3ded.arm'
        'build/release-linux-arm/ioquake3.arm'
    )

    wget $__archive_url/Q3DemoPaks.zip
    unzip -o Q3DemoPaks.zip -d "$md_inst"
    rm Q3DemoPaks.zip
}

function configure_quake3() {
    addPort "$md_id" "quake3" "Quake III Arena" "LD_LIBRARY_PATH=lib $md_inst/ioquake3.arm"

    mkRomDir "ports/quake3"

    # Add user for no sudo run
    usermod -a -G video $user
}
