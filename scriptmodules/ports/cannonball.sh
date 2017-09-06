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
rp_module_desc="Cannonball - An Enhanced OutRun Engine"
rp_module_help="You need to unzip your OutRun set B from latest MAME (outrun.zip) to $romdir/ports/cannonball. They should match the file names listed in the roms.txt file found in the roms folder. You will also need to rename the epr-10381a.132 file to epr-10381b.132 before it will work."
rp_module_licence="NONCOM https://raw.githubusercontent.com/djyt/cannonball/master/docs/license.txt"
rp_module_section="opt"

function depends_cannonball() {
    local depends=(cmake libsdl2-dev libboost-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_cannonball() {
    gitPullOrClone "$md_build" https://github.com/djyt/cannonball.git
    sed -i "s/-march=armv6 -mfpu=vfp -mfloat-abi=hard//" "$md_build/cmake/sdl2_rpi.cmake" "$md_build/cmake/sdl2gles_rpi.cmake"
}

function build_cannonball() {
    local target
    mkdir build
    cd build
    if isPlatform "rpi"; then
        target="sdl2gles_rpi"
    elif isPlatform "mali"; then
        target="sdl2gles"
    else
        target="sdl2gl"
    fi
    cmake -G "Unix Makefiles" -DTARGET=$target ../cmake/
    make clean
    make
    md_ret_require="$md_build/build/cannonball"
}

function install_cannonball() {
    md_ret_files=(
        'build/cannonball'
        'roms/roms.txt'
    )

    mkdir -p "$md_inst/res"
    cp -v res/*.bin "$md_inst/res/"
    cp -v res/config_sdl2.xml "$md_inst/config.xml.def"
}

function configure_cannonball() {
    addPort "$md_id" "cannonball" "Cannonball - OutRun Engine" "pushd $md_inst; $md_inst/cannonball; popd"

    mkRomDir "ports/$md_id"

    moveConfigFile "config.xml" "$md_conf_root/$md_id/config.xml"
    moveConfigFile "hiscores.xml" "$md_conf_root/$md_id/hiscores.xml"

    [[ "$md_mode" == "remove" ]] && return

    copyDefaultConfig "$md_inst/config.xml.def" "$md_conf_root/$md_id/config.xml"

    cp -v roms.txt "$romdir/ports/$md_id/"

    chown -R $user:$user "$romdir/ports/$md_id" "$md_conf_root/$md_id"

    ln -snf "$romdir/ports/$md_id" "$md_inst/roms"
}
