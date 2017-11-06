#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="gngeopi"
rp_module_desc="NeoGeo emulator GnGeoPi"
rp_module_help="ROM Extension: .zip\n\nCopy your GnGeoPi roms to $romdir/neogeo\n\nCopy the required BIOS file neogeo.zip BIOS to $romdir/neogeo"
rp_module_licence="NONCOM https://github.com/ymartel06/GnGeo-Pi/blob/master/gngeo/COPYING"
rp_module_section="opt"
rp_module_flags="!x86 !mali !kms"

function depends_gngeopi() {
    getDepends libsdl1.2-dev
}

function sources_gngeopi() {
    gitPullOrClone "$md_build" https://github.com/ymartel06/GnGeo-Pi.git
}

function build_gngeopi() {
    cd gngeo
    chmod +x configure
    ./configure --disable-i386asm --prefix="$md_inst"
    make clean
    # not safe for building in parallel
    make -j1
    md_ret_require="$md_build/gngeo/src/gngeo"
}

function install_gngeopi() {
    cd gngeo
    make install
    mkdir -p "$md_inst/neogeobios"
}

function configure_gngeopi() {
    mkRomDir "arcade"
    mkRomDir "neogeo"

    # move old config to new location
    moveConfigDir "$home/.gngeo" "$md_conf_root/neogeo"

    if [[ ! -f "$md_conf_root/neogeo/gngeorc" ]]; then
        # add default controls for keyboard p1/p2
        cat > "$md_conf_root/neogeo/gngeorc" <<\_EOF_
p1control A=K122,B=K120,C=K97,D=K115,START=K49,COIN=K51,UP=K273,DOWN=K274,LEFT=K276,RIGHT=K275,MENU=K27
p2control A=K108,B=K59,C=K111,D=K112,START=K50,COIN=K52,UP=K264,DOWN=K261,LEFT=K260,RIGHT=K262,MENU=K27
_EOF_
        chown -R $user:$user "$md_conf_root/neogeo/gngeorc"
    fi

    addEmulator 0 "$md_id" "arcade" "$md_inst/bin/gngeo -i $romdir/neogeo -B $md_inst/neogeobios %ROM%"
    addEmulator 0 "$md_id" "neogeo" "$md_inst/bin/gngeo -i $romdir/neogeo -B $md_inst/neogeobios %ROM%"
    addSystem "arcade"
    addSystem "neogeo"
}
