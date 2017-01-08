#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="minivmac"
rp_module_desc="Macintosh Plus Emulator"
rp_module_help="ROM Extensions: .dsk \n\nCopy your Macintosh Plus disks to $romdir/macintoshplus \n\n You need to copy the Macintosh bios file vMac.ROM into "$biosdir" and System Tools.dsk to $romdir"
rp_module_section="exp"
rp_module_flags="!mali"

function sources_minivmac() {
    gitPullOrClone "$md_build" https://github.com/vanfanel/minivmac_sdl2.git
}

function build_minivmac() {
    make
    md_ret_require="$md_build/minivmac"
}

function install_minivmac() {
    md_ret_files=(
        'minivmac'
    )
}

function configure_minivmac() {
    mkRomDir "macintoshplus"

    mkUserDir "$md_conf_root/macintoshplus"

    ln -sf "$biosdir/vMac.ROM" "$md_inst/vMac.ROM"

    addEmulator 1 "$md_id" "macintoshplus" "pushd $md_inst; $md_inst/minivmac $romdir/macintoshplus/System\ Tools.dsk %ROM%; popd"
    addSystem "macintoshplus"
}
