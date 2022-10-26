#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pcsx2-qt"
rp_module_desc="PS2 emulator PCSX2 - New Qt frontend (AVX2)"
rp_module_help="ROM Extensions: .bin .iso .img .mdf .z .z2 .bz2 .cso .chd .ima .gz\n\nCopy your PS2 roms to $romdir/ps2\n\nCopy the required BIOS file to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/PCSX2/pcsx2/master/COPYING.GPLv3"
rp_module_section="exp"
rp_module_flags="!all x86"

function depends_pcsx2-qt() {
    getDepends jq
}

function install_bin_pcsx2-qt() {
    mkdir -p "$md_inst/bin"
    version=$(curl --silent "https://api.pcsx2.net/v1/latestReleasesAndPullRequests" | jq -r ".nightlyReleases | .data | .[0] | .version")
    wget --content-disposition https://github.com/PCSX2/pcsx2/releases/download/$version/pcsx2-$version-linux-AppImage-64bit-AVX2-Qt.AppImage -O "$md_inst/bin/pcsx2.AppImage"
    chmod +x "$md_inst/bin/pcsx2.AppImage"
}

function configure_pcsx2-qt() {
    mkRomDir "ps2"
    addEmulator 0 "$md_id" "ps2" "$md_inst/bin/rpcs2.AppImage %ROM% -fullscreen -batch"
    addEmulator 1 "$md_id-nogui" "ps2" "$md_inst/bin/rpcs2.AppImage %ROM% -fullscreen -nogui"
    addSystem "ps2"
}
