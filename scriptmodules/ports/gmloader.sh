#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="gmloader"
rp_module_desc="GMLoader - play GameMaker Studio games for Android on non-Android operating systems"
rp_module_help="ROM Extensions: .apk .APK\n\nCopy your APK files to $romdir/ports/droidports and then re-run this installer."
rp_module_repo="git https://github.com/JohnnyonFlame/droidports.git master faf3970"
rp_module_licence="GPL3 https://raw.githubusercontent.com/JohnnyonFlame/droidports/master/LICENSE.md"
rp_module_section="exp"
rp_module_flags="!all rpi4"

function depends_gmloader() {
    getDepends libopenal-dev libfreetype6-dev zlib1g-dev libbz2-dev libpng-dev libzip-dev libsdl2-image-dev cmake
}

function sources_gmloader() {
    gitPullOrClone
}

function build_gmloader() {
    mkdir build && cd build
    cmake CMakeLists.txt -DCMAKE_BUILD_TYPE=Release -DPLATFORM=linux -DPORT=gmloader ..
    make
    md_ret_require="$md_build/build/gmloader"
}

function install_gmloader() {
    md_ret_files="build/gmloader"
}

function configure_gmloader() {
    while read apk; do
        local apk_filename="${apk##*/}"
        local apk_basename="${apk_filename%.*}"
        addPort "$md_id" "droidports" "$apk_basename" "$md_inst/gmloader %ROM%" "$apk"
        moveConfigDir "$home/.config/$apk_basename" "$md_conf_root/droidports/$apk_basename"
    done < <(find "$romdir/ports/droidports" -maxdepth 1 -type f -iname "*.apk")

    mkRomDir "ports/droidports"
}
