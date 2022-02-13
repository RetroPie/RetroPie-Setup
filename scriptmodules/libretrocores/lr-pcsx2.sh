#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-pcsx2"
rp_module_desc="PlayStation 2 emulator - PCSX2 port for libretro"
rp_module_help="ROM Extensions: .elf .iso .ciso .chd .cso .bin .mdf .nrg .dump .gz .img .m3u"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/pcsx2/main/COPYING.GPLv3"
rp_module_repo="git https://github.com/libretro/pcsx2.git main"
rp_module_section="exp"
rp_module_flags="!all x86"

function depends_lr-pcsx2() {
    local depends=(ccache liblzma-dev zlib1g-dev libwxgtk3.0-gtk3-dev libgtk2.0-dev libgtk-3-dev libxml2-dev libpcap-dev libaio-dev)
    getDepends "${depends[@]}"
}

function sources_lr-pcsx2() {
    gitPullOrClone
}

function build_lr-pcsx2() {
    mkdir build
    cd build
    cmake .. -DLIBRETRO=ON -DCMAKE_BUILD_TYPE=Release
    make clean
    make -j$(nproc)
    md_ret_require="$md_build/build/pcsx2/pcsx2_libretro.so"
}

function install_lr-pcsx2() {
    md_ret_files=(
        'build/pcsx2/pcsx2_libretro.so'
    )
}

function configure_lr-pcsx2() {
    mkRomDir "ps2"

    ensureSystemretroconfig "ps2"

    addEmulator 1 "$md_id" "ps2" "$md_inst/pcsx2_libretro.so"

    addSystem "ps2"
}
