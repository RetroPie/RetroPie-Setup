#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="drastic"
rp_module_desc="NDS emu - DraStic"
rp_module_help="ROM Extensions: .nds .zip\n\nCopy your Nintendo DS roms to $romdir/nds"
rp_module_section="exp"
rp_module_flags="!mali !x86 !armv6"

function install_bin_drastic() {
    wget -O- -q http://drastic-ds.com/drastic_rpi.tar.bz2 | tar -xvj --strip-components=1 -C "$md_inst"
}

function configure_drastic() {
    mkRomDir "nds"
    ensureSystemretroconfig "nds"

    addEmulator 0 "$md_id" "nds" "$md_inst/drastic %ROM%"
    addSystem "nds"
}
