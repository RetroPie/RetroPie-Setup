#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mupen64plus"
rp_module_desc="N64 emulator MUPEN64Plus"
rp_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy your N64 roms to $romdir/n64"
rp_module_section="main"

function depends_mupen64plus() {
    local depends=(cmake libsamplerate0-dev libspeexdsp-dev )
    getDepends "${depends[@]}"
}

function install_bin_mupen64plus() {
    wget -O- -q "http://www.retrorangepi.org/mupen64plus.tar.gz" | tar -xvz -C /
}

function configure_mupen64plus() {
    addSystem 0 "$md_id" "n64" "/usr/local/bin/mupen64plus --noosd --fullscreen --plugindir /usr/local/lib/mupen64plus --gfx mupen64plus-video-rice.so %ROM%"

}
