#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="uqm"
rp_module_desc="The Ur-Quan Masters (Port of DOS game Star Control 2)"
rp_module_licence="NONCOM https://raw.githubusercontent.com/davidben/uqm/nacl/COPYING"
rp_module_section="opt"
rp_module_flags="!mali !kms"

function _update_hook_uqm() {
    # to show as installed in retropie-setup 4.x
    hasPackage uqm && mkdir -p "$md_inst"
}

function depends_uqm() {
    ! hasPackage raspberrypi-bootloader && return 0
    getDepends debhelper devscripts libmikmod-dev libsdl1.2-dev libopenal-dev libsdl-image1.2-dev libogg-dev libvorbis-dev
}

function sources_uqm() {
    ! hasPackage raspberrypi-bootloader && return 0
    local url="http://http.debian.net/debian/pool/contrib/u/uqm/"
    for file in uqm_0.6.2.dfsg-9.1~deb8u1.dsc uqm_0.6.2.dfsg.orig.tar.gz uqm_0.6.2.dfsg-9.1~deb8u1.diff.gz; do
        wget -nv -O"$file" "$url/$file"
    done
}

function build_uqm() {
    ! hasPackage raspberrypi-bootloader && return 0
    dpkg-source -x uqm_0.6.2.dfsg-9.1~deb8u1.dsc
    cd uqm-0.6.2.dfsg
    dpkg-buildpackage -us -uc
}

function install_uqm() {
    cp -v *.deb "$md_inst"
    # uqm is missing on raspbian
    if hasPackage raspberrypi-bootloader; then
        dpkg -i *.deb
        aptInstall uqm-content uqm-music uqm-voice
    else
        aptInstall uqm uqm-content uqm-music uqm-voice
    fi
}

function install_bin_uqm() {
    rp_installBin
    # uqm is missing on raspbian
    if hasPackage raspberrypi-bootloader; then
        cd "$md_inst"
        dpkg -i *.deb
        aptInstall uqm-content uqm-music uqm-voice
    else
        aptInstall uqm uqm-content uqm-music uqm-voice
    fi
}

function remove_uqm() {
    aptRemove uqm uqm-content uqm-music uqm-voice
}

function configure_uqm() {
    addPort "$md_id" "uqm" "Ur-quan Masters" "uqm -f"
}
