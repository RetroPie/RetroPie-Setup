#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ti99sim"
rp_module_desc="TI-99/SIM - Texas Instruments Home Computer Emulator"
rp_module_help="ROM Extension: .ctg\n\nCopy your TI-99 games to $romdir/ti99\n\nCopy the required BIOS file TI-994A.ctg (case sensitive) to $biosdir"
rp_module_licence="GPL2 http://www.mrousseau.org/programs/ti99sim/"
rp_module_section="exp"
rp_module_flags=" !kms"

function depends_ti99sim() {
    getDepends libsdl1.2-dev libssl-dev
}

function sources_ti99sim() {
    downloadAndExtract "http://www.mrousseau.org/programs/ti99sim/archives/ti99sim-0.15.0.src.tar.xz" "$md_build" 1
}

function build_ti99sim() {
    make
}

function install_ti99sim() {
    md_ret_files=(
        'bin/ti99sim-sdl'
    )
}

function configure_ti99sim() {
    mkRomDir "ti99"
    moveConfigDir "$home/.ti99sim" "$md_conf_root/ti99/"
    ln -sf "$biosdir/TI-994A.ctg" "$md_inst/TI-994A.ctg"

    addEmulator 1 "$md_id" "ti99" "pushd $md_inst; $md_inst/ti99sim-sdl -f=2 %ROM%; popd"
    addSystem "ti99"
}
