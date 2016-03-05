#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="cannonball"
rp_module_desc="cannonball - An Enhanced OutRun Engine"
rp_module_menus="4+"
rp_module_flags="!x11 !mali"

function depends_cannonball() {
    getDepends libsdl2-dev libboost-dev
}

function sources_cannonball() {
    gitPullOrClone "$md_build" https://github.com/djyt/cannonball.git
    sed -i "s/-march=armv6 -mfpu=vfp -mfloat-abi=hard//" $md_build/cmake/sdl2_rpi.cmake $md_build/cmake/sdl2gles_rpi.cmake
}

function build_cannonball() {
    mkdir build
    cd build
    cmake -G "Unix Makefiles" -DTARGET=sdl2gles_rpi -DCMAKE_INSTALL_PREFIX:PATH="$md_inst" ../cmake/
    make
    md_ret_require="$md_build/build/cannonball"
}

function install_cannonball() {
    mkRomDir "ports"
    mkRomDir "ports/cannonball"
    cp build/cannonball "$md_inst"
    ln -s "$romdir/ports/cannonball" "$md_inst/roms"
    mkdir "$md_inst/res/"
    cp -R roms/* "$romdir/ports/cannonball/"
    cp res/tilemap.bin "$md_inst/res/"
    cp res/tilepatch.bin "$md_inst/res/"
}

function configure_cannonball() {
    addPort "$md_id" "cannonball" "Cannonball - OutRun Engine" "pushd $md_inst; $md_inst/cannonball; popd"
    cp "$md_build/res/config.xml" "$configdir/$md_id"
    touch "$configdir/$md_id/hiscores.xml"
    chown $user:$user "$configdir/$md_id/config.xml"
    chown $user:$user "$configdir/$md_id/hiscores.xml"
    ln -s "$configdir/$md_id/config.xml" "$md_inst/config.xml"
    ln -s "$configdir/$md_id/hiscores.xml" "$md_inst/hiscores.xml"

    __INFMSGS+=("You need to unzip your OutRun set B from latest MAME (outrun.zip) to $romdir/ports/cannonball/. They should match the file names listed in the roms.txt file found in the roms folder. You will also need to rename the epr-10381a.132 file to epr-10381b.132 before it will work.")
}
