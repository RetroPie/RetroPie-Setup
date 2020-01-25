#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="opentyrian"
rp_module_desc="Open Tyrian - port of the DOS shoot-em-up Tyrian"
rp_module_licence="GPL2 https://bitbucket.org/opentyrian/opentyrian/raw/3e3d6b925342a5891d8b937989dc50b563ff83dd/COPYING"
rp_module_section="opt"
rp_module_flags="dispmanx !mali"

function depends_opentyrian() {
    getDepends libsdl1.2-dev libsdl-net1.2-dev mercurial
}

function sources_opentyrian() {
    hg clone https://bitbucket.org/opentyrian/opentyrian "$md_build"
    # don't replace our CFLAGS
    sed -i "s/CFLAGS := -pedantic/CFLAGS += -pedantic/" Makefile
}

function build_opentyrian() {
    rpSwap on 512
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/opentyrian"
}

function install_opentyrian() {
    make install prefix="$md_inst"
}

function game_data_opentyrian() {
    if [[ ! -d "$romdir/ports/opentyrian/data" ]]; then
        cd "$__tmpdir"
        # get Tyrian 2.1 (freeware game data)
        downloadAndExtract "$__archive_url/tyrian21.zip" "$romdir/ports/opentyrian/data" -j
        chown -R $user:$user "$romdir/ports/opentyrian"
    fi
}

function configure_opentyrian() {
    addPort "$md_id" "opentyrian" "OpenTyrian" "$md_inst/bin/opentyrian --data $romdir/ports/opentyrian/data"

    mkRomDir "ports/opentyrian"

    moveConfigDir "$home/.config/opentyrian" "$md_conf_root/opentyrian"

    # Enable dispmanx by default.
    setDispmanx "$md_id" 1

    [[ "$md_mode" == "install" ]] && game_data_opentyrian
}
