#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="coolcv"
rp_module_desc="CoolCV Colecovision Emulator"
rp_module_help="ROM Extensions: .bin .col .rom .zip\n\nCopy your Colecovision roms to $romdir/coleco"
rp_module_licence="PROP"
rp_module_section="opt"
rp_module_flags="!x86 !x11 !mali !kms"

function depends_coolcv() {
    getDepends libsdl2-dev
}

function install_bin_coolcv() {
    downloadAndExtract "$__archive_url/coolcv.tar.gz" "$md_inst" --strip-components 1
    patchVendorGraphics "$md_inst/coolcv_pi"
}

function configure_coolcv() {
    mkRomDir "coleco"

    moveConfigFile "$home/coolcv_mapping.txt" "$md_conf_root/coleco/coolcv_mapping.txt"

    addEmulator 1 "$md_id" "coleco" "$md_inst/coolcv_pi %ROM%"
    addSystem "coleco"
}
