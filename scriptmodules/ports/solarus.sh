#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="solarus"
rp_module_desc="solarus - An Open Source Zelda LttP Engine"
rp_module_licence="GPL3 https://raw.githubusercontent.com/solarus-games/solarus/dev/license.txt"
rp_module_section="opt"
rp_module_flags="noinstclean !aarch64"

# Version numbers
solarus_ver="1.4.5"
zsdx_ver="1.10.3"
zsxd_ver="1.10.3"
zrothse_ver="1.0.8"

function depends_solarus() {
    getDepends cmake libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libluajit-5.1-dev libphysfs-dev libopenal-dev libmodplug-dev libvorbis-dev zip unzip
}

function sources_solarus() {
    downloadAndExtract "http://www.solarus-games.org/downloads/solarus/solarus-$solarus_ver-src.tar.gz" "$md_build" --strip-components 1
    downloadAndExtract "https://gitlab.com/solarus-games/zsdx/-/archive/release-$zsdx_ver/zsdx-release-$zsdx_ver.tar.gz" "$md_build"
    downloadAndExtract "https://gitlab.com/solarus-games/zsxd/-/archive/release-$zsxd_ver/zsxd-release-$zsxd_ver.tar.gz" "$md_build"
    downloadAndExtract "https://gitlab.com/solarus-games/zelda-roth-se/-/archive/release-$zrothse_ver/zelda-roth-se-release-$zrothse_ver.tar.gz" "$md_build"
}

function build_solarus() {
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    cd ../zsdx-$zsdx_ver
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    cd ../zsxd-$zsxd_ver
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    cd ../zelda-roth-se-$zrothse_ver
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    md_ret_require=(
        "$md_build/build/solarus_run"
        "$md_build/zsdx-release-$zsdx_ver/data.solarus"
        "$md_build/zsxd-release-$zsxd_ver/data.solarus"
        "$md_build/zelda-roth-se-release-$zrothse_ver/data.solarus"
    )
}

function install_solarus() {
    cd build
    make install
    cd ../zsdx-release-$zsdx_ver/
    make install
    cd ../zsxd-release-$zsxd_ver/
    make install
    cd ../zelda-release-roth-se-$zrothse_ver/
    make install
}

function configure_solarus() {
    addPort "$md_id" "zsdx" "Solarus Engine - Zelda Mystery of Solarus DX" "LD_LIBRARY_PATH=$md_inst/lib $md_inst/bin/solarus_run $md_inst/share/solarus/zsdx/"
    addPort "$md_id" "zsxd" "Solarus Engine - Zelda Mystery of Solarus XD" "LD_LIBRARY_PATH=$md_inst/lib $md_inst/bin/solarus_run $md_inst/share/solarus/zsxd/"
    addPort "$md_id" "zelda_roth_se" "Solarus Engine - Zelda Return of the Hylian SE" "LD_LIBRARY_PATH=$md_inst/lib $md_inst/bin/solarus_run $md_inst/share/solarus/zelda_roth_se/"

    # symlink the library so it can be found on all platforms
    ln -sf "$md_inst"/lib/*/libsolarus.so "$md_inst/lib"

    moveConfigDir "$home/.solarus" "$md_conf_root/solarus"

    chown -R $user:$user "$md_inst"/share/solarus/*/data.solarus
}
