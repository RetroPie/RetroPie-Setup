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
    downloadAndExtract "http://www.solarus-games.org/downloads/solarus/solarus-1.5.3-src.tar.gz" "$md_build" 1
    downloadAndExtract "http://www.zelda-solarus.com/downloads/zsdx/zsdx-1.11.0.tar.gz" "$md_build"
    downloadAndExtract "http://www.zelda-solarus.com/downloads/zsxd/zsxd-1.11.0.tar.gz" "$md_build"
    downloadAndExtract "http://www.zelda-solarus.com/downloads/zelda-roth-se/zelda-roth-se-1.1.0.tar.gz" "$md_build"
    wget http://www.zelda-solarus.com/zs/download/zxd2-src/ -O zelda-xd2-1.0.6.tar.gz
    tar xzf zelda-xd2-1.0.6.tar.gz
}

function build_solarus() {
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$md_inst" -DSOLARUS_GUI=OFF
    make
    cd ../zsdx-1.11.0
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    cd ../zsxd-1.11.0
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    cd ../zelda-roth-se-1.1.0
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    cd ../zelda-xd2-1.0.6
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    md_ret_require=(
        "$md_build/build/solarus-run"
        "$md_build/zsdx-1.11.0/data.solarus"
        "$md_build/zsxd-1.11.0/data.solarus"
        "$md_build/zelda-roth-se-1.1.0/data.solarus"
        "$md_build/zelda-xd2-1.0.6/data.solarus"
    )
}

function install_solarus() {
    cd build
    make install
    cd ../zsdx-1.11.0/
    make install
    cd ../zsxd-1.11.0/
    make install
    cd ../zelda-roth-se-1.1.0/
    make install
    cd ../zelda-xd2-1.0.6/
    make install
}

function configure_solarus() {
	addPort "$md_id" "zsdx" "Solarus Engine - Zelda Mystery of Solarus DX" "LD_LIBRARY_PATH=/usr/lib $md_inst/bin/solarus-run $md_inst/share/solarus/zsdx/"
    	addPort "$md_id" "zsxd" "Solarus Engine - Zelda Mystery of Solarus XD" "LD_LIBRARY_PATH=/usr/lib $md_inst/bin/solarus-run $md_inst/share/solarus/zsxd/"
    	addPort "$md_id" "zelda_roth_se" "Solarus Engine - Zelda Return of the Hylian SE" "LD_LIBRARY_PATH=/usr/lib $md_inst/bin/solarus-run $md_inst/share/solarus/zelda_roth_se/"
    	addPort "$md_id" "zelda_xd2_mercuris_chess" "Solarus Engine - Zelda XD2 Mercuris Chess" "LD_LIBRARY_PATH=/usr/lib $md_inst/bin/solarus-run $md_inst/share/solarus/zelda_xd2_mercuris_chess/"

    if isPlatform "tinker"; then
    	sudo mv /opt/retropie/port/solarus/lib/arm-linux-gnueabihf/* /usr/lib/arm-linux-gnueabihf/
    	sudo rm -rf /opt/retropie/port/solarus/lib/arm-linux-gnueabihf
	ln -sf /usr/lib/arm-linux-gnueabihf/libsolarus.so "$md_inst/lib/libsolarus.so"
    else
    	# symlink the library so it can be found on all platforms
    	ln -sf "$md_inst"/lib/*/libsolarus.so "$md_inst/lib"
    fi
    moveConfigDir "$home/.solarus" "$md_conf_root/solarus"

    chown -R $user:$user "$md_inst"/share/solarus/*/data.solarus
}
