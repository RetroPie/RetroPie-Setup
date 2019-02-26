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

function depends_solarus() {
    getDepends cmake libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libluajit-5.1-dev libphysfs-dev libopenal-dev libmodplug-dev libvorbis-dev zip unzip
}

function sources_solarus() {
    downloadAndExtract "http://www.solarus-games.org/downloads/solarus/solarus-1.4.5-src.tar.gz" "$md_build" --strip-components 1
    downloadAndExtract "http://www.zelda-solarus.com/downloads/zsdx/zsdx-1.10.3.tar.gz" "$md_build"
    downloadAndExtract "http://www.zelda-solarus.com/downloads/zsxd/zsxd-1.10.3.tar.gz" "$md_build"
    downloadAndExtract "http://www.zelda-solarus.com/downloads/zelda-roth-se/zelda-roth-se-1.0.8.tar.gz" "$md_build"
}

function build_solarus() {
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    cd ../zsdx-1.10.3
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    cd ../zsxd-1.10.3
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    cd ../zelda-roth-se-1.0.8
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    md_ret_require=(
        "$md_build/build/solarus_run"
        "$md_build/zsdx-1.10.3/data.solarus"
        "$md_build/zsxd-1.10.3/data.solarus"
        "$md_build/zelda-roth-se-1.0.8/data.solarus"
    )
}

function install_solarus() {
    cd build
    make install
    cd ../zsdx-1.10.3/
    make install
    cd ../zsxd-1.10.3/
    make install
    cd ../zelda-roth-se-1.0.8/
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
